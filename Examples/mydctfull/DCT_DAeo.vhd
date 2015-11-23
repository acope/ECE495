---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------


-- This project is based on 'FIR_DA_full', but here we allow B to be different from NH.
-- We also allow to use an L different than 4. Also, we include a parameter that decides
-- whether to use the Xilinx primitives for LUT implementation (useful when the PRR is made of the LUTs)
-- or not (useful when the PRR is the entire FIR Filter core).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--TODO: Try to use the recursive even-odd decomposition (up to 4x4)
library work;
use work.pack_xtras.all;

entity DCT_DAeo is
	generic (N: INTEGER:=8; -- Size of the DCT... 16 and 8 are suported --> only even-odd decomposition
				NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
				L: INTEGER:= 4;  -- Input bit-width of the LUTs storing the coeffs, i.e. we use L-input LUTs
				B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
				op: INTEGER:= 0;  -- Output truncation scheme:
										-- op = 0: saturation/truncation, op = 1: truncation, op = 2: Use max bit-width
				NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
				NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).
										--   0 <= NO <= L_DCT, 0 <= NQ <= NH+B-2
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
	port (	clock: in std_logic;	
				X_in : in std_logic_2d(N - 1 downto 0, B-1 downto 0); -- input values
				E : in std_logic; -- enable for all the input registers
				Z_out : out std_logic_2d (N - 1 downto 0, L_FIR_out(NH,B,N,NO, op) - 1 downto 0); -- final output				
				rst: in std_logic; -- reset (high-level) for the shift register of 'v' (to protect it right after PR)
				v: out std_logic); -- valid output
end DCT_DAeo;

architecture structure of DCT_DAeo is

	type str_array is array (N-1 downto 0) of string (1 to 31);	
	subtype idx_range is integer range 0 to N+NH;
		
	function get_names (N: in integer) return str_array is				
		variable files_LUT: str_array;
		variable LB, LEN: integer;		
	begin		
	   -- We can not create arrays of unconstrained strings.
		-- Virtex-4 compiler: We do not need to specify the length of files_LUT(i)
		-- Virtex-6 compiler: We do need to specify the length for files_LUT(i)
		-- For the even-odd decomposition, we have:
		--  "DCTeo{N}_NH{NH}_LUT_values[{i+1}].txt"
		--    NH can only be 10,12,14,16
		--    The base length is 27 characters
		--    If N > 9 --> we add 2 characters. If N <= 9 --> we add 1 character
		--    If (i+1) > 9 --> we add 2 characters. If (i+1) <= 9 --> we add 1 character
		--    Max length: 31. Min length: 29
		-- The function that reads the file 'files_LUT(i)' receive it as an unconstrained string.
		if N > 9 then
			LB:= 27 + 2;
		else
			LB:= 27 + 1;
		end if;
		
		for i in 0 to N-1 loop
			if i+1 > 9 then
				LEN:= LB + 2;
			else
				LEN:= LB + 1;
			end if;
			
			files_LUT(i)(1 to LEN) := "DCTeo"&idx_range'image(N)&"_NH"&idx_range'image(NH)&"_LUT_values["&idx_range'image(i+1)&"].txt";	
			-- Function to_string exists but it can only be used in VHDL2008
		end loop;
      -- names are from LUT_values[1] to LUT_values[N]
		return files_LUT;
	end function;

	constant files_LUT: str_array := get_names(N);
	
-- Bear in mind:
-- 16x16 DCT: computed as 2 independent 8x8 vector by matrix multiplications
-- Thus, for a N-point DCT (that would need a NxN matrix), we only need 2 N/2xN/2 matrices (for 16x16 case)

	constant M: INTEGER:= N/2; -- Size of each group (either odd or even group of W's)
	-- It can also be seen as the # of effective multiplications of each dot product
	-- unlike the FIR filter, N is NOT the # of multiplications when the coefficientes are nonsymmetric
	-- but it is rather the DCT size. The even-odd decomposition lets us consider dot products of size N/2
	
	constant size_I: INTEGER:= B+1; -- size of the inputs that get rearranged by Distributed Arithmetic
	-- unlike the FIR filter, the DCT is considered as nonsymmetric, but we perform a butterfly summation
	-- that leaves the new input W to be of size_I. If the DCT coefficients of each row of the N/2 by N/2
	-- matrix were symemtric, the new input would be of size 'size_I+1', but this is not the case here.
	
   -- original DCT computation (no even-odd decomposition):
	-- Input size: B bits.... # of multiplications in the dot product: N.. NH: coefficient bit-width
	constant L_DCT: INTEGER:= NH + B + ceil_log2(N+1) - 1; -- max. filter bit-width. L_fbk + LV >= L_DCT (assumption)
	--constant L_DCT: INTEGER:= NH + size_I + ceil_log2(M+1) - 1;
	---- # of products of each sum: N/2
	---- # of bits of each product input (W): size_I	
	---- this formulae would also work: TODO: see which formula is better
	-- the DCT (each Z_out (i)), computes the addition (N/2 adds) of the multiplications of W(size_I bits)
	-- with the coefficients (NH bits)
	
	constant NY: INTEGER:= L_FIR_out(NH,B,N,NO, op);
	
	constant REG_LEVELS: natural := ceil_log2(size_I) + ceil_log2(M/L) + 2;
	-- REG_LEVELS: # of cycles it takes for the output to appear from the moment the input is captured on the 1st register
		
	type chunk_X is array (N-1 downto 0) of std_logic_vector(B-1 downto 0);
	signal X: chunk_X;
	
	type chunk_W is array (N-1 downto 0) of std_logic_vector (B downto 0);	
	signal W, SX: chunk_W;
	
	type chunk_UF is array(M/L - 1 downto 0) of std_logic_vector(L*size_I -1 downto 0);
	signal UF_even, UF_odd: chunk_UF;
	
	type chunk_Z is array (N-1 downto 0) of std_logic_vector (NY-1 downto 0);
	signal Z: chunk_Z;
	
	signal UF_2d_even, UF_2d_odd: std_logic_2d (M/L -1 downto 0, L*size_I -1 downto 0);
		
	component sum_FIR_blocks
			generic (file_LUT: STRING:= "LUT_values[1].txt";
						USE_PRIM: STRING:= "YES";
						NY : INTEGER;
						NH: INTEGER:= 16;
						B: INTEGER:= 8;
						size_I: INTEGER:= 9;
						L_FIR: INTEGER:=33;
						M  : INTEGER:= 4;
						L  : INTEGER:= 4;
						NO : INTEGER:= 16;
						NQ : INTEGER:= 15;
						op: INTEGER:= 0);  -- Output truncation scheme
			port ( UF_2d : in std_logic_2d;
					 clock: in std_logic;		 
					 Y  : out std_logic_vector (NY - 1 downto 0));
	end component;
	
	signal resetn: std_logic;
	
begin

resetn <= not (rst);

   a0: assert (N = 16 or N = 8)
	    report "For even-odd decomposition, N can only be 16 or 8 so far"
		 severity error;
		 
   a1: assert (M rem L = 0)
       report "M must be a multiple of L!!"
       severity error;
		 
	a2: assert ((L = 4 or L = 5 or L = 6 or L = 7 or L = 8) and (USE_PRIM = "YES")) or USE_PRIM = "NO"
       report "L can only be 4, 5, 6, 7, 8 when USE_PRIM = 'YES'!!"
       severity error;
		 
   -- Inputs are registered	
	gi: for i in 0 to N-1 generate
		   gj: for j in 0 to B-1 generate
			      -- these ffs do not need a synchronous clear
				   gd: dffes port map (X_in(i,j), '1', '1', clock, '0', E, X(i)(j));
			    end generate;
		 end generate;
	
   -- Even-odd decomposition:
   -- Butterfly: W's are obtained from X's
	-- X: X(0), X(1), ... X(N-1). Bit-width = B
	-- W: W(0), W(1), ... W(N-1). Bit-width = B+1		 
	--        even indices  (ie)                  odd indices (io)
	--    W(0) <= X(0) + X(N-1)					W(1) <= X(0) - X(N-1)
	--    W(2) <= X(1) + X(N-2)					W(3) <= X(1) - X(N-2)
	--    ...
	--    W(ie) <= X(ie/2) + X(N-(ie/2+1))		W(io) <= X(floor(io/2)) - X(N-(floor(io/2)+1))
	--    ...
	--    W(N-2) <= X(N/2-1) + X(N/2)			W(N-1) <= X(N/2-1) - X(N/2)
	-- The Ws with even indices multiply T(N/2)
	-- The Ws with odd indices multiply D(N/2)
	-- The coefficients in T(N/2), D(N/2) are nonsymmetric.
	bW: for i in 0 to N/2 - 1 generate
			SX(i) <= X(i)(B-1)&X(i); -- sign extension of the X's
			SX(N-(i+1)) <= X(N-(i+1))(B-1)&X(N-(i+1));
			
			-- Ws with even indices: W(2*i)   <= SX(i) + SX(N -1 - i)
--			be: lpm_add_sub generic map (LPM_WIDTH => B+1, LPM_DIRECTION => "ADD")
--				port map (dataa => SX(i), datab => SX(N-(i+1)), result => W(2*i));
			be: my_addsub generic map (N => B+1)
                port map (addsub => '0', x => SX(i), y => SX(N-(i+1)), s => W(2*i));
			
			-- Ws with odd indices: W(2*i+1) <= SX(i) - SX(N -1 - i)
--			bo: lpm_add_sub generic map (LPM_WIDTH => B+1, LPM_DIRECTION => "SUB")
--				 port map (dataa => SX(i), datab => SX(N-(i+1)), result => W(2*i + 1));			
			bo: my_addsub generic map (N => B+1)
                port map (addsub => '1', x => SX(i), y => SX(N-(i+1)), s => W(2*i + 1));

		end generate;
	
	-- W is rearranged into:
	-- UF_even(i), UF_odd(i): group of vectors that go into the Filter Block 'i' packed as one vector 
	--        This is basically the rearrangement of the vectors W(i*L) to W((i+1)*L-1)
	--        The length of each UF_even(i), UF_odd(i) is L*sizeI bits
	-- UF_even(0)        UF_odd(0)
	-- UF_even(1)        UF_odd(1)
	-- ...               ...     
	-- UF_even(M/L-1)    UF_odd(M/L-1)
	sr: for i in 0 to M/L - 1 generate -- run over the filter blocks
			ga: for j in 0 to size_I - 1  generate -- run over each column of the matrix made by: W(i*L) to W((i+1)*L-1)
					gb: for k in 0 to L - 1 generate -- run over each bit of the previous column
							UF_even(i)(k + j*L) <= W(2*k + 2*i*L)(j);
							UF_odd(i)(k + j*L) <= W(2*k + 1 + 2*i*L)(j);
						 end generate;
				 end generate;
		end generate;
		-- Example: M = 8, L = 4: Let's look at UF_even(0), UF_odd(0) when j = 0 (i.e. collection of LSBs)
		--UF_even(0)(0-->L-1) <-- LSB of W(0), W(2), W(4), W(6)
		--UF_odd (0)(0-->L-1) <-- LSB of W(1), W(3), W(5), W(7)
		--UF_even(1)(0-->L-1) <-- LSB of W(8), W(10), W(12), W(14)
		--UF_odd (1)(0-->L-1) <-- LSB of W(9), W(11), W(13), W(15)

   -- UF_even, UF_odd is a collection of vectors, i.e. a matrix
	-- We could pass this to the next block, but VHDL does not support parametric user-defined types
	-- This is why, we define the std_logic_2d instead that does not need to be defined as bounded.
	--  Thus, UF_2d_even, UF_2d_odd let us pass the matrix to another block parametrically.
	-- UF_2d_even, UF_2d_odd look exactly like UF_even, UF_odd. They are just different types indexed slightly different.
	st: for i in 0 to M/L - 1 generate -- M must be multiple of L
			gc: for j in 0 to size_I*L - 1  generate
						UF_2d_even(i,j) <= UF_even(i)(j);
						UF_2d_odd(i,j) <= UF_odd(i)(j);
				 end generate;
		 end generate;
		 	
	-- Here, we plug the UFs into the FIR_blocks	
	sk: for u in 0 to M-1 generate
	      -- row 'u' of T(N/2)
			ge: sum_FIR_blocks generic map (files_LUT(u), USE_PRIM, NY, NH, B, size_I, L_DCT, M, L, NO, NQ, op)
				 port map (UF_2d_even, clock, Z(2*u));
		   
			-- row 'u' of D(N/2)
			go: sum_FIR_blocks generic map (files_LUT(u+M), USE_PRIM, NY, NH, B, size_I, L_DCT, M, L, NO, NQ, op)
				 port map (UF_2d_odd, clock, Z(2*u + 1));
       end generate;
   
	go: for i in 0 to N-1 generate
		   gp: for j in 0 to NY-1 generate
					Z_out(i,j) <= Z(i)(j);
			    end generate;
		 end generate;
		 
-- shift register for the valid output:		 
--gsh: lpm_shiftreg generic map (lpm_width => REG_LEVELS, lpm_direction => "RIGHT")
--	  port map (clock => clock, enable => '1', shiftin => E, aclr => rst, shiftout => v);	 
gsh: my_shiftreg generic map (N => REG_LEVELS, DIR => "RIGHT")
     port map (clock => clock, resetn => resetn, shiftin => E, E => '1', shiftout => v);
           	  
end structure;
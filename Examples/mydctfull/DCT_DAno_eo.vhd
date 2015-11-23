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

library work;
use work.pack_xtras.all;

entity DCT_DAno_eo is
	generic (N: INTEGER:=8; -- Size of the DCT: 2,3,4,5,6,7,8,16 are suported (no even-odd decomposition)
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
end DCT_DAno_eo;

architecture structure of DCT_DAno_eo is

	type str_array is array (N-1 downto 0) of string (1 to 29);	
	subtype idx_range is integer range 0 to N+NH;
		
	function get_names (N: in integer) return str_array is				
		variable files_LUT: str_array;
		variable LB, LEN: integer;		
	begin		
	   -- We can not create arrays of unconstrained strings.
		-- Virtex-4 compiler: We do not need to specify the length of files_LUT(i)
		-- Virtex-6 compiler: We do need to specify the length for files_LUT(i)
		-- For the no even-odd decomposition, we have:
		--  "DCT{N}_NH{NH}_LUT_values[{i+1}].txt"
		--    NH can only be 10,12,14,16
		--    The base length is 25 characters
		--    If N > 9 --> we add 2 characters. If N <= 9 --> we add 1 character
		--    If (i+1) > 9 --> we add 2 characters. If (i+1) <= 9 --> we add 1 character
		--    Max length: 29. Min length: 27
		-- The function that reads the file 'files_LUT(i)' receive it as an unconstrained string.
		if N > 9 then
			LB:= 25 + 2;
		else
			LB:= 25 + 1;
		end if;
		
		for i in 0 to N-1 loop
			if i+1 > 9 then
				LEN:= LB + 2;
			else
				LEN:= LB + 1;
			end if;
			files_LUT(i)(1 to LEN) := "DCT"&idx_range'image(N)&"_NH"&idx_range'image(NH)&"_LUT_values["&idx_range'image(i+1)&"].txt";	
			-- Function to_string exists but it can only be used in VHDL2008
		end loop;
      -- names are from LUT_values[1] to LUT_values[N]
		return files_LUT;
	end function;

	constant files_LUT: str_array := get_names(N);
	
-- For a N-point DCT, we need a NxN matrix

	constant M: INTEGER:= N; -- Size of each group (either odd or even group of W's)
	-- It can also be seen as the # of effective multiplications of each dot product
	-- N: DCT size. It is laso the # of multiplications when the coefficients are nonsymmetric
	
	constant size_I: INTEGER:= B; -- size of the inputs that get rearranged by Distributed Arithmetic
	-- The rows of the DCT matrix are nonsymmetric. If the DCT coefficients of each row of the N by N
	-- matrix were symemtric, we could add them, but this is not the case here.
	
   -- DCT computation (no even-odd decomposition):
	-- Input size: B bits.... # of multiplications in the dot product: N.. NH: coefficient bit-width
	constant L_DCT: INTEGER:= NH + B + ceil_log2(N+1) - 1; -- max. filter bit-width. L_fbk + LV >= L_DCT (assumption)
	
	constant NY: INTEGER:= L_FIR_out(NH,B,N,NO, op);
	
	constant REG_LEVELS: natural := ceil_log2(size_I) + ceil_log2(M/L) + 2;
	-- REG_LEVELS: # of cycles it takes for the output to appear from the moment the input is captured on the 1st register
		
	type chunk_X is array (N-1 downto 0) of std_logic_vector(B-1 downto 0);
	signal X: chunk_X;
		
	type chunk_UF is array(M/L - 1 downto 0) of std_logic_vector(L*size_I -1 downto 0);
	signal UF: chunk_UF;
	
	type chunk_Z is array (N-1 downto 0) of std_logic_vector (NY-1 downto 0);
	signal Z: chunk_Z;
	
	signal UF_2d: std_logic_2d (M/L -1 downto 0, L*size_I -1 downto 0);
		
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
   a0: assert (N = 2 or N=3 or N=4 or N=5 or N=6 or N=7)
	    report "N can only be 2,3,4,5,6,7 for no even-odd decomposition"
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
	
	-- X is rearranged into:
	-- UF(i): Group of vectors that go into the Filter Block 'i' packed as one vector 
	--        This is basically the rearrangement of the vectors X(i*L) to X((i+1)*L-1)
	--        The length of each UF(i) is L*sizeI bits
	-- UF(0)     
	-- UF(1)     
	-- ...       
	-- UF(M/L-1) 
	sr: for i in 0 to M/L - 1 generate -- run over the filter blocks
			ga: for j in 0 to size_I - 1  generate -- run over each column of the matrix made by: X(i*L) to X((i+1)*L-1)
					gb: for k in 0 to L - 1 generate -- run over each bit of the previous column
							UF(i)(k + j*L) <= X(k + i*L)(j);
						 end generate;
				 end generate;
		end generate;
		-- Example: M = 8, L = 4: Let's look at UF(0) when j = 0 (i.e. collection of LSBs)
		--UF(0)(0-->L-1) <-- LSB of X(0), X(1), X(2), X(3)		
		--UF(1)(0-->L-1) <-- LSB of X(4), X(5), X(6), X(7)

   -- UF a collection of vectors, i.e. a matrix
	-- We could pass this to the next block, but VHDL does not support parametric user-defined types
	-- This is why, we define the std_logic_2d instead that does not need to be defined as bounded.
	--  Thus, UF lets us pass the matrix to another block parametrically.
	-- UF_2d looks exactly like UF They are just different types indexed slightly different.
	st: for i in 0 to M/L - 1 generate -- M must be multiple of L 
			gc: for j in 0 to size_I*L - 1  generate
						UF_2d(i,j) <= UF(i)(j);						
				 end generate;
		 end generate;
		 	
	-- Here, we plug the UFs into the FIR_blocks	
	sk: for u in 0 to M-1 generate
	      -- row 'u' of T(N)
			gu: sum_FIR_blocks generic map (files_LUT(u), USE_PRIM, NY, NH, B, size_I, L_DCT, M, L, NO, NQ, op)
				 port map (UF_2d, clock, Z(u));		   
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
---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

-- This project is based on 'FIR_DA_full_v4'
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

entity DCT_DA is
	generic (N: INTEGER:=8; -- Size of the DCT. 8,16 are supported --> only even-odd decomposition
	                        -- 2,3,4,5,6,7 are supported --> no even-odd decomposition
				NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])				
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
				Z_out : out std_logic_2d (N - 1 downto 0, L_FIR_out(NH,B,N,NO,op) - 1 downto 0); -- final output				
				rst: in std_logic; -- reset (high-level) for the shift register of 'v' (to protect it right after PR)
				v: out std_logic); -- valid output
end DCT_DA;

architecture structure of DCT_DA is
	
	component DCT_DAeo
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
	end component;
	
	component DCT_DAno_eo
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
	end component;
	
	-- Input bit-width of the LUTs storing the coeffs, i.e. we use L-input LUTs
	-- N=8,16 --> L = 4 and even-odd decomposition
   -- N=2,3,4,5,6,7 -> L=2,3,4,5,6,7 and no even-odd decomposition
   function get_L (N: in integer) return integer is
		variable L: integer;
	begin
		if N = 8 or N = 16 or N =32 or N=64 then
			L := 4; -- N/2 is multiple of L
		else
			L := N; -- N is multiple of L=2,3,4,5,6,7
		end if;
		return L;
	end function;
	
	-- 'L' can not be a parameter. It depends on N. Unlike the case of the FIR filter, N is seldom used beyond 16
	constant L: integer:= get_L(N);
	
begin
 
a0: assert (N=64 or N=32 or N=16 or N=8 or N=2 or N=3 or N=4 or N=5 or N=6 or N=7)
	 report "N can only be 8,16, 2,3,4,5,6,7"
	 severity error;
	 
--  L=4,5,6,7,8: USE_PRIM can be either "YES" or "NO"
--  L=2,3: the parameter USE_PRIM has to be "NO"
a1: assert ((L = 4 or L = 5 or L = 6 or L = 7 or L = 8) and (USE_PRIM = "YES")) or USE_PRIM = "NO"
    report "L can only be 4, 5, 6, 7, 8 when USE_PRIM = 'YES'!!"
    severity error;
	 
a2: assert (NH = 10 or NH = 12 or NH = 14 or NH = 16)
    report "NH can only be 10,12,14,16"
    severity error;
		 
g0: if N = 8 or N = 16 generate
			d0: DCT_DAeo generic map (N, NH, L, B, op, NO, NQ, USE_PRIM)
			    port map (clock, X_in, E, Z_out, rst, v);
	 end generate;
	 
-- careful with USE_PRIM here, if N=2,3 (i.e. L=2,3), we can't use USE_PRIM="YES"	 
g1: if N/=8 and N/=16 generate
			d1: DCT_DAno_eo generic map (N, NH, L, B, op, NO, NQ, USE_PRIM)
			    port map (clock, X_in, E, Z_out, rst, v);
    end generate; 
  
end structure;
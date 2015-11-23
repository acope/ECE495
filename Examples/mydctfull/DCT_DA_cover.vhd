---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

-- This project is based on 'FIR_DA_fullv4'
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--TODO: when building 16x16 from 8x8 and 4x4, let's see how we can reuse the 4x4 to build the others
-- we might create a DCT_DA_reuse module that takes as inputs X's (in array form)
library work;
use work.pack_xtras.all;

-- DCT 1D
-- Cases allowed:
-- N = 2,3,4,5,6,7 --> no even-odd decomposition (L=2,3,4,5,6,7)
-- N = 8,16 --> even-odd decomposition (L=4,4)

-- NH = 10,12,14,16
entity DCT_DA_cover is
	generic (N: INTEGER:=8; -- Size of the DCT. 8,16 are supported --> only even-odd decomposition
	                        -- 2,3,4,5,6,7 are supported --> no even-odd decomposition
				NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
				B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of w[n] (if exists) is 'B+1'
				op: INTEGER:= 0;  -- Output truncation scheme:
										-- op = 0: saturation/truncation, op = 1: truncation, op = 2: Use max bit-width
				NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
				NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).
										--   0 <= NO <= L_FIR, 0 <= NQ <= NH+B-2
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive. N=2,3 (L=2,3) is not allowed here
				                           -- "NO" --> uses simple VHDL statement. All N's (all L's) are allowed here
	port (	clock: in std_logic;	
				X : in std_logic_vector (N*B -1 downto 0);
				E : in std_logic; -- enable for the input registers
				Z : out std_logic_vector (N*L_FIR_out(NH,B,N,NO,op) - 1 downto 0); 				
				rst: in std_logic;
				v: out std_logic);
end DCT_DA_cover;

architecture structure of DCT_DA_cover is
		
	component DCT_DA
		generic (N: INTEGER:=8; -- Size of the DCT... 16 and 8 are suported --> only even-odd decomposition
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
					Z_out : out std_logic_2d (N - 1 downto 0, L_FIR_out(NH,B,N,NO, op) - 1 downto 0); -- final output				
					rst: in std_logic; -- reset for the shift register of 'v'
					v: out std_logic); -- valid output
	end component;
	
	constant NY: INTEGER:= L_FIR_out(NH,B,N,NO, op);
	signal X_in: std_logic_2d(N - 1 downto 0, B-1 downto 0);
	signal Z_out: std_logic_2d (N - 1 downto 0, L_FIR_out(NH,B,N,NO, op) - 1 downto 0); 

begin

-- X: N groups of 'B' bits, one after the other, ordered from MSB to LSB
gi: for i in 0 to N-1 generate
	   gj: for j in 0 to B-1 generate
				X_in(i,j) <= X((N-(i+1))*B + j);
		    end generate;
			 
		gb: for j in 0 to NY-1 generate
				Z((N-(i+1))*NY + j) <= Z_out(i,j);
			 end generate;
	 end generate;

g1: DCT_DA generic map (N, NH, B, op, NO, NQ, USE_PRIM)
    port map (clock=>clock, X_in => X_in, E=>E, Z_out => Z_out, rst => rst, v => v);

end structure;
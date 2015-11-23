---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

-- DCT 2D
-- Cases allowed (and successfully compiled):
-- N = 2,3,4,5,6,7 --> no even-odd decomposition (L=2,3,4,5,6,7)
-- N = 8,16 --> even-odd decomposition (L=4,4)

-- NH = 10,12,14,16

-- We fix the number of output bits of the first DCT to be the same as the number of input bits of the second DCT
entity DCT_2d is
	generic (N: INTEGER:= 8;-- Size of the DCT
				NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
				B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
														
				-- Output bits for first 1D DCT: [NOa NOa-1]
				NO_a: INTEGER:= 16;
				-- Final output format, or output format of the second 1D DCT				
				NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
				NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).										
				USE_PRIM: STRING:= "YES"; -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
				IMPLEMENTATION: STRING:= "fullypip"); -- "onetrans", "fullypip".
	port (	clock: in std_logic;	
			   rst: in std_logic; -- High-level reset, initializes FSM, counters, and 'v' shift register
				X : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
				E : in std_logic; -- enable for all the register chain
				Y : out std_logic_vector (N*NO - 1 downto 0); 
				v: out std_logic); -- output validity signal
end DCT_2d;

architecture structure of DCT_2d is

	component DCT_2d_onetrans
	-- IMPORTANT: we input 'N' columns, after that we have to wait 'N-1' cycles to place the next batch of
	-- 'N' columns. This is because the transposing matrix needs N-1 cycles to transmit data to the other 1d dct
		generic (N: INTEGER:= 8;-- Size of the DCT
					NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
					B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
															
					-- Output bits for first 1D DCT: [NOa NOa-1]
					NO_a: INTEGER:= 16;
					-- Final output format, or output format of the second 1D DCT				
					NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
					NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).										
					USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
														-- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
		port (	clock: in std_logic;	
					resetn: in std_logic; -- initializes FSM and counters
					X : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
					E : in std_logic; -- enable for all the register chain
					Y : out std_logic_vector (N*NO - 1 downto 0); 
					v: out std_logic); -- output validity signal
	end component;
	
	component DCT_2d_fullypip
		generic (N: INTEGER:= 8;-- Size of the DCT
					NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
					B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
															
					-- Output bits for first 1D DCT: [NOa NOa-1]
					NO_a: INTEGER:= 16;
					-- Final output format, or output format of the second 1D DCT				
					NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
					NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).										
					USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
														-- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
		port (	clock: in std_logic;	
					resetn: in std_logic; -- initializes FSM and counters
					X : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
					E : in std_logic; -- enable for all the register chain
					Y : out std_logic_vector (N*NO - 1 downto 0); 
					v: out std_logic); -- output validity signal
	end component;

signal resetn: std_logic;

begin

resetn <= not (rst);

a1: assert (IMPLEMENTATION = "onetrans" or IMPLEMENTATION = "fullypip")
    report "wrong implementation modifier"
    severity error;
	 
g0: if IMPLEMENTATION = "onetrans" generate
			d0: DCT_2d_onetrans generic map (N, NH, B, NO_a, NO, NQ, USE_PRIM)
			    port map (clock, resetn, X, E, Y, v);
	 end generate;

g1: if IMPLEMENTATION = "fullypip" generate
			d1: DCT_2d_fullypip generic map (N, NH, B, NO_a, NO, NQ, USE_PRIM)
			    port map (clock, resetn, X, E, Y, v);
    end generate;

end structure;

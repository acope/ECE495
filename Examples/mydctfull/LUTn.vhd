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

use std.textio.all;
use ieee.std_logic_textio.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.pack_xtras.all;

entity LUTn is -- L-to-LO LUT
	generic (NH: INTEGER:= 12; -- number of bits of each of the h[n] values
				L: INTEGER:= 4; -- # of bits of ub, i.e. we have a L-input LUT
				BT: INTEGER:= 1; -- BT = '1' ==> ub = uMSB (we take fB which is fb multiplied by -1), Bb = '0' ==> ub /= uMSB (we do nothing)
				P:  INTEGER:= 8; -- pointer in the file, so that it takes the 2^NL values from position P as the fb's
										-- P: 1 --> M/NL
										-- Given P, the position in the file from which we start is:
										-- 2(P-1)(2^NL+1) + 1 + (2^NL + 1)BT
										-- P can be better understood as the number of filter block we are working on
										-- e.g.: P = 1 ==> we are working with the first filter block of NL coefficients
				file_LUT: STRING:= "LUT_values.txt";
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.
										
	port (	ub: in std_logic_vector (L-1 downto 0); 
				fb: out std_logic_vector ((NH + ceil_log2(L)) - 1 downto 0 ) -- NH + ceil_log2(L): max # of bits for fb
			); 
end LUTn;

architecture structure of LUTn is
	
	constant LO: INTEGER:= NH + ceil_log2(L); -- output bits of the LUT L-to-LO
	constant START_POINTER: INTEGER:= 2*(P-1)*(2**L + 1) + 1 + (2**L + 1)*BT;
	
	type chunk is array (2**L - 1 downto 0) of std_logic_vector(LO - 1 downto 0);
	type chunk_col is array (LO -1 downto 0) of std_logic_vector(2**L -1 downto 0);
	
-- we have to read the LUT values from the text file given the pointer.	
	impure function ReadfromFile (FileName : in string; SP: in integer) return chunk is
		FILE IN_FILE  : text open read_mode is FileName; -- VHDL 93 declaration
		variable BUFF : line;
		variable val  : chunk;
	begin
	   if SP /= 1 then 
			for j in 1 to SP-1 loop
				readline (IN_FILE, BUFF); -- It positionates the pointer to where we should start
			end loop;
		end if;
			
		for i in 0 to 2**L-1 loop
			readline (IN_FILE, BUFF);
			read (BUFF, val(i));				 
		end loop;

		return val;
	end function;

	function Get_Columns (LUT_val: in chunk) return chunk_col is
		variable t: std_logic_vector (2**L - 1 downto 0);
		variable val: chunk_col;
	begin
		for i in LO-1 downto 0 loop -- moving along columns
			for j in 0 to 2**L-1 loop -- moving along rows
				t(j) := LUT_val(j)(i); -- gets the bits of column 'i'
			end loop;
			-- t: (t[2**L-1] .... t[0])
			val(i):= t;
		end loop;
		
		return val; -- val(i) = [val(i)(2**L-1) val(i)(2**L-2) ... val(i)(0)]
	end function;
	
	constant LUT_val: chunk := ReadFromFile(file_LUT, START_POINTER);
	constant data: chunk_col:= Get_Columns(LUT_val);
	
begin

   p1: if USE_PRIM = "NO" generate
		    fb <= LUT_val(conv_integer(ub));
		 end generate;
	
	-- Primitive usage: most efficient implementation of LUTs:
	-- ROM16x1 == LUT 4-to-1
	-- ROM32x1 == LUT 5-to-1
	-- ROM64x1 == LUT 6-to-1
	-- ROM128x1 == LUT 7-to-1 --> efficientely implemented in 1 CLB
	-- ROM256x1 == LUT 8-to-1 --> efficiently implemented in 2 contiguous CLBs
	p2: if USE_PRIM = "YES" generate
		    gi: for i in 0 to LO-1 generate
				     l4: if L = 4 generate
							   ROM16X1_inst : ROM16X1 generic map (INIT => to_bitvector(data(i)))
								-- INIT = [INIT(15) INIT(14) .... INIT(0)]
								-- A3A2A1A0 = "1111" --> O = INIT(15)
								-- A3A2A1A0 = "0000" --> O = INIT(0)
								port map (
		 							O => fb(i),  -- ROM output
									A0 => ub(0), -- ROM address[0]
									A1 => ub(1), -- ROM address[1]
									A2 => ub(2), -- ROM address[2]
									A3 => ub(3));-- ROM address[3]
						   end generate;
							
				     l5: if L = 5 generate
							   ROM32X1_inst : ROM32X1 generic map (INIT => to_bitvector(data(i)))
								-- INIT = [INIT(31) INIT(30) .... INIT(0)]
								-- A4A3A2A1A0 = "11111" --> O = INIT(31)
								-- A4A3A2A1A0 = "00000" --> O = INIT(0)
								port map (
		 							O => fb(i),  -- ROM output
									A0 => ub(0), -- ROM address[0]
									A1 => ub(1), -- ROM address[1]
									A2 => ub(2), -- ROM address[2]
									A3 => ub(3), -- ROM address[3]
									A4 => ub(4));-- ROM address[4]
						   end generate;		
							
					  l6: if L = 6 generate
							   ROM64X1_inst : ROM64X1 generic map (INIT => to_bitvector(data(i)))
								-- INIT = [INIT(63) INIT(62) .... INIT(0)]
								-- A5A4A3A2A1A0 = "111111" --> O = INIT(63)
								-- A5A4A3A2A1A0 = "000000" --> O = INIT(0)
								port map (
		 							O => fb(i),  -- ROM output
									A0 => ub(0), -- ROM address[0]
									A1 => ub(1), -- ROM address[1]
									A2 => ub(2), -- ROM address[2]
									A3 => ub(3), -- ROM address[3]
									A4 => ub(4), -- ROM address[4]
									A5 => ub(5));-- ROM address[5]
						   end generate;
							
					  l7: if L = 7 generate
							   ROM128X1_inst : ROM128X1 generic map (INIT => to_bitvector(data(i)))
								-- INIT = [INIT(127) INIT(126) .... INIT(0)]
								-- A6A5A4A3A2A1A0 = "1111111" --> O = INIT(127)
								-- A6A5A4A3A2A1A0 = "0000000" --> O = INIT(0)
								port map (
		 							O => fb(i),  -- ROM output
									A0 => ub(0), -- ROM address[0]
									A1 => ub(1), -- ROM address[1]
									A2 => ub(2), -- ROM address[2]
									A3 => ub(3), -- ROM address[3]
									A4 => ub(4), -- ROM address[4]
									A5 => ub(5), -- ROM address[5]
									A6 => ub(6));-- ROM address[5]
						   end generate;
							
					  l8: if L = 8 generate
							   ROM256X1_inst : ROM256X1 generic map (INIT => to_bitvector(data(i)))
								-- INIT = [INIT(255) INIT(254) .... INIT(0)]
								-- A7A6A5A4A3A2A1A0 = "11111111" --> O = INIT(255)
								-- A7A6A5A4A3A2A1A0 = "00000000" --> O = INIT(0)
								port map (
		 							O => fb(i),  -- ROM output
									A0 => ub(0), -- ROM address[0]
									A1 => ub(1), -- ROM address[1]
									A2 => ub(2), -- ROM address[2]
									A3 => ub(3), -- ROM address[3]
									A4 => ub(4), -- ROM address[4]
									A5 => ub(5), -- ROM address[5]
									A6 => ub(6), -- ROM address[5]
									A7 => ub(7));-- ROM address[5]
						   end generate;						
			     end generate;										
		 end generate;

end structure;
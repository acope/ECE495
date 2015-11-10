-- 3. HIGH SPEED ARCHITECTURE.
-- This is a simple circuit with no register in the inputs and outputs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.pack_xtras.all;

-- Assumption: LUT_val has 256 positions of 8 bits.
entity LUT_NItoNO is
	generic ( NI: INTEGER:= 8;
				 NO: INTEGER:= 8;
				 F: INTEGER:= 5; -- type of function (1..5)
				 USE_PRIM: STRING:= "YES"; -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
				 file_LUT: STRING:= "LUT_values.txt"); -- file where the numerical values are stored
	-- Function F = 1: Gamma correction - 0.5
	-- Function F = 2: Gamma correction - 2
	-- Function F = 3: Inverse Gamma correction - 0.5
	-- Function F = 4: Inverse Gamma correction - 2
	-- Function F = 5: Contrast Stretching - Alpha = 2, m = 0.5
	-- ...
	port (	LUT_in: in std_logic_vector (NI-1 downto 0);
				LUT_out: out std_logic_vector (NO-1 downto 0)
			);
end LUT_NItoNO;

architecture structure of LUT_NItoNO is

	constant START_POINTER: INTEGER:= (F-1)*(2**NI + 1) + 1;	
	type chunk is array (2**NI -1 downto 0) of std_logic_vector (NO-1 downto 0);
	type chunk_col is array(NO-1 downto 0) of std_logic_vector(2**NI -1 downto 0);
	
	impure function ReadfromFile (FileName: in string; P: in integer) return chunk is
		FILE IN_FILE  : text open read_mode is FileName; -- VHDL 93 declaration
		variable BUFF : line;
		variable val  : chunk;
	begin
	   if P /= 1 then 
			for j in 1 to P-1 loop
				readline (IN_FILE, BUFF); -- It positionates the pointer to where we should start
			end loop;
		end if;
		
		for i in 0 to 2**NI - 1 loop
			readline (IN_FILE, BUFF);
			read (BUFF, val(i));
		end loop;

		return val;
	end function;
	
	function Get_Columns(LUT_val: in chunk) return chunk_col is
		variable t: std_logic_vector (2**NI - 1 downto 0);
		variable val: chunk_col;
	begin
		for i in NO-1 downto 0 loop -- moving along columns
			for j in 0 to 2**NI - 1 loop -- moving along rows
				t(j) := LUT_val(j)(i); -- gets the bits of column 'i'
			end loop;
			-- t: (t[2**NI-1] ... t[0])
			val(i) := t;						
		end loop;
		
		return val; -- val(i) = [val(i)(2**NI-1) val(i)(2**NI-2) ... val(i)(0)]
	end function;	
	
	constant LUT_val: chunk:= ReadFromFile(file_LUT, START_POINTER); -- binary values
	constant data: chunk_col:= Get_Columns(LUT_val);

begin
	  
li: for i in 0 to NO-1 generate
			lut_NI : LUT_NIto1 generic map (NI => NI, data => data(i), USE_PRIM => USE_PRIM)
					 port map (ILUT => LUT_in, OLUT => LUT_out(i));
	 end generate;

end structure;
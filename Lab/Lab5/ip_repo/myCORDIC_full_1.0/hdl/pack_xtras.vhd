-- Here we declare components, functions, procedures, and types defined by the user
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;

package pack_xtras is

	--type std_logic_vector2 is array (natural range <>, natural range <>) of std_logic;
	
	function ceil_log2(dato: in integer) return integer;
	
	function getN(s: in string) return integer;
		
	component LUT_NItoNO
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
	end component;

	component LUT_NIto1
		generic ( NI: INTEGER:= 8;
				  data: in std_logic_vector;
				  USE_PRIM: STRING:= "YES"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
		port (	ILUT: in std_logic_vector (NI-1 downto 0);				
					OLUT: out std_logic
				);
	end component;
		
	component LUT_group
		generic ( NC: INTEGER:= 8; -- number of cores (NI-to-NO LUTs)
					 NI: INTEGER:= 8;
					 NO: INTEGER:= 8;
					 F: INTEGER:= 1; -- type of function (1..5)
					 USE_PRIM: STRING:= "YES"; -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
					 file_LUT: STRING:= "LUT_values.txt");  -- contains all the functions needed (one after the other)
		port ( dyn_in: in std_logic_vector (NC*NI - 1 downto 0);
				 dyn_out: out std_logic_vector (NC*NO - 1 downto 0));
	end component;

	component dffe
		 port ( d : in  STD_LOGIC;
				  clrn: in std_logic:= '1';
				  prn: in std_logic:= '1';
				  clk : in  STD_LOGIC;
				  ena: in std_logic;
				  q : out  STD_LOGIC);
	end component;
	
end package pack_xtras;

package body pack_xtras is
	
	function ceil_log2(dato: in integer) return integer is
		variable i, valor: integer;
	begin
		i:= 0; valor:= dato;
		while valor /= 1 loop
			valor := valor - (valor/2); -- 'valor/2' truncates the fractional part towards zero
			i:= i + 1;					-- Ej.: 15/2 = 7
		end loop;
		return i;
	end function ceil_log2;
		
	function getN(s: in string) return integer is
		variable i: integer;
	begin
		if s = "GRAY" then
			i:= 1;
		elsif s = "RGB" then
			i:= 3;
		else
			i:= 0;
		end if;
		return i;
	end function getN;
	
end package body pack_xtras;
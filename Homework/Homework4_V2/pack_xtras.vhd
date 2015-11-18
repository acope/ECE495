-- Here we declare components, functions, procedures, and types defined by the user

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package pack_xtras is

	type std_logic_2d is array (NATURAL RANGE <>, NATURAL RANGE <>) of std_logic;
	type int_vector is array(natural range <>) of integer;
		
	function Get_X(LV,FB: in integer) return int_vector;
		
	function ceil_log2(dato: in integer) return integer;
	
	function ceil_2(x: in integer) return integer;

	component my_pashiftreg
		generic (N: INTEGER:= 4;
					DIR: STRING:= "LEFT");
		port ( clock, resetn: in std_logic;
				 din, E, s_l: in std_logic; -- din: shiftin input
				 D: in std_logic_vector (N-1 downto 0);
				 Q: out std_logic_vector (N-1 downto 0);
				 shiftout: out std_logic);
	end component;
	
	component my_rege
		generic (N: INTEGER:= 4);
		port ( clock, resetn: in std_logic;
				 E, sclr: in std_logic; -- sclr: Synchronous clear
				 D: in std_logic_vector (N-1 downto 0);
				 Q: out std_logic_vector (N-1 downto 0));
	end component;
	
	component my_addsub
		generic (N: INTEGER:= 4);
		port(	addsub   : in std_logic;
				x, y     : in std_logic_vector (N-1 downto 0);
				s        : out std_logic_vector (N-1 downto 0);
				overflow : out std_logic;
				cout     : out std_logic);
	end component;
	
end package pack_xtras;

package body pack_xtras is

	function Get_X(LV,FB: in integer) return int_vector is
		variable val : int_vector(LV downto 0);
	begin
		val(0) := FB; -- Dummy Level: Level 0 --> this is not a real level, but it useful to use it as Level 0
		              -- FB: number of summations to perform
		for i in 1 to LV loop
			val(i) := ceil_2(val(i-1));-- this function takes ceil(val(i-1)/2)
		end loop;
		
		return val;
	end function;
	
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

	function ceil_2(x: in integer) return integer is -- This function obtains ceil(x/2)
		variable result: integer;
	begin
		if x rem 2 = 0 then -- if x is even?
			result:= x/2;
		else					 -- if x is odd
			result:= 1 + (x/2);
		end if;
		return result;
	end function ceil_2;
	
end package body pack_xtras;
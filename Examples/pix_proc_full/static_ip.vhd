library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

entity static_ip is
	generic ( NC: INTEGER:= 4; -- number of cores (NI-to-NO LUTs)
			  NI: INTEGER:= 9;
			  NO: INTEGER:= 9;
			  USE_PRIM: STRING:= "YES"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
	port ( dyn_in:  in std_logic_vector(NC*NI - 1 downto 0);
		   dyn_out: out std_logic_vector(NC*NO - 1 downto 0) );	
end static_ip;

architecture structure of static_ip is
	
	constant file_LUT: STRING:= "LUT_values"&integer'image(NI)&"to"&integer'image(NO)&".txt";		
	constant F: INTEGER:= 1;	
   -- Type of function (1..5):
	-- Function 1: Gamma correction - 0.5
	-- Function 2: Gamma correction - 2
	-- Function 3: Inverse Gamma correction - 0.5
	-- Function 4: Inverse Gamma correction - 2
	-- Function 5: Contrast Stretching - Alpha = 2, m = 0.5
	-- ....
		
begin
	
-- dyn_in, dyn_out are std_logic_vectors because EDK has problems with custom data types
gL: LUT_group generic map (NC, NI, NO, F, USE_PRIM, file_LUT)
	 port map (dyn_in => dyn_in, dyn_out => dyn_out);
	 
end structure;


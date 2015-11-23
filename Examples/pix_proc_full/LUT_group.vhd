library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

entity LUT_group is
	generic ( NC: INTEGER:= 4; -- number of cores (NI-to-NO LUTs)
			  NI: INTEGER:= 8;
			  NO: INTEGER:= 8;
			  F: INTEGER:= 1; -- type of function (1..5)
			  USE_PRIM: STRING:= "YES"; -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
			  file_LUT: STRING:= "LUT_values.txt");  -- contains all the functions needed (one after the other)
	port ( dyn_in: in std_logic_vector (NC*NI - 1 downto 0);
		   dyn_out: out std_logic_vector (NC*NO - 1 downto 0));
end LUT_group;

architecture structure of LUT_group is

	type chunkI is array (NC - 1 downto 0) of std_logic_vector (NI-1 downto 0);
	type chunkO is array (NC - 1 downto 0) of std_logic_vector (NO-1 downto 0);
	
	signal in_data: chunkI;
	signal out_data: chunkO;
	
begin

-- dyn_in, dyn_out: |1st pixel|2nd pixel|3rd pixel|...|NCth pixel|
   -- dyn_in(1st pixel) = in_data(0)
   -- dyn_in(2nd pixel) = in_data(1)
   -- dyn_in(NCth pixel) = in_data(NC-1)
gs: for i in 0 to NC - 1 generate
			in_data(NC-i-1) <= dyn_in( (i+1)*NI - 1 downto i*NI );
			dyn_out( (i+1)*NO - 1 downto i*NO ) <= out_data(NC-i-1);
	 end generate;

ga: for i in 0 to NC - 1 generate
		gi: LUT_NItoNO generic map (NI => NI, NO => NO, F => F, USE_PRIM => USE_PRIM, file_LUT => file_LUT)
		    port map (LUT_in => in_data(i), LUT_out => out_data(i));			 
	 end generate;

end structure;
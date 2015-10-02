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
use ieee.std_logic_arith.all;


entity mycounter is
	port ( clock, resetn, E: in std_logic;
		   Q: out std_logic_vector (3 downto 0));
end mycounter;

architecture Behavioral of mycounter is
	signal Qt: integer range 0 to 15;
begin

	process (resetn, clock, E)
	variable flg : integer := 0;
	begin
		if resetn = '0' then
			Qt <= 14;
		elsif (clock'event and clock = '1') then
			if E = '1' then	
			     if flg = 0 then
			         if Qt = 15 then
			             Qt <= 14;
			         elsif Qt = 0 then
			             Qt <= 1;
			             flg := 1;
			         else
			             Qt <= Qt - 2;
			         end if; --if Qt=15
			     else
			         if Qt = 15 then
                        flg := 0;
                        Qt <= 14;
                     else
                        Qt <= Qt + 2;
                     end if; --if Qt=15
			     end if; --if flg								
			end if;--if E
		end if;--if resetn
	end process;
	Q <= conv_std_logic_vector(Qt,4);

end Behavioral;


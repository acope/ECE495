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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dffe is
    Port ( d : in  STD_LOGIC;
	        clrn: in std_logic:= '1';
			  prn: in std_logic:= '1';
           clk : in  STD_LOGIC;
			  ena: in std_logic;
           q : out  STD_LOGIC);
end dffe;

architecture behaviour of dffe is

begin
	process (clk, ena, clrn, prn)
	begin
		if clrn = '0' then
			q <= '0';
		elsif prn = '0' then
			q <= '1';
		elsif (clk'event and clk='1') then
			if ena = '1' then
				q <= d;
			end if;
		end if;
	end process;

end behaviour;
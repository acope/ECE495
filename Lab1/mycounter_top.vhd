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
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.math_real.ceil;


entity mycounter_top is
	port ( clock, reset, E: in std_logic;
		   Q: out std_logic_vector (3 downto 0));
end mycounter_top;

architecture Behavioral of mycounter_top is
    component my_genpulse
        generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
        port (clock, resetn, E: in std_logic;
                Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
                z: out std_logic);
    end component;
    
    component mycounter
        port ( clock, resetn, E: in std_logic;
               Q: out std_logic_vector (3 downto 0));
    end component;
    
    signal z: std_logic;
    signal resetn: std_logic;
    
begin

resetn <= not (reset);

   a1: my_genpulse generic map (COUNT => 125*(10**6)/2) -- each count is of T*(10**6)/2, where T = 1/125 MHz (ZYBO Board)
       port map (clock => clock, resetn => resetn, E => E, z => z);
   a2: mycounter port map (clock =>  clock, resetn => resetn, E => z , Q => Q);

end Behavioral;


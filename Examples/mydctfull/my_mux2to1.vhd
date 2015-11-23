---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity my_mux2to1 is
	 generic (N: INTEGER:= 8 ); -- bit-width of the inputs
    port (A, B : in std_logic_vector (N-1 downto 0);
          S : in std_logic;
          O : out std_logic_vector(N-1 downto 0));
end my_mux2to1;

architecture archi of my_mux2to1 is
begin

    process (A, B, S)
    begin
      case s is 
         when '0' => O <= A;
         when '1' => O <= B;         
         when others => O <= A;
      end case;
    end process;
	 
end archi;
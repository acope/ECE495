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

-- 2 styles for a busmux 4-to-1
entity my_busmux3to1 is
   generic (N: INTEGER:= 8); -- Length of each input signal
	port (a,b,c: in std_logic_vector (N-1 downto 0);
	      s: in std_logic_vector (1 downto 0);
	      y_r, y_t: out std_logic_vector (N-1 downto 0));
end my_busmux3to1;

architecture structure of my_busmux3to1 is

begin

	with s select
		y_r <= a when "00",
		       b when "01",
			    c when others;

	y_t <= a when s = "00" else
	       b when s = "01" else
		   c;
			 
end structure;


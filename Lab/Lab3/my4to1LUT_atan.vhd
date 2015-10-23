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

entity my4to1LUT is
	port ( ILUT: in std_logic_vector (4 downto 0);
	       OLUT: out std_logic);
end my4to1LUT;

architecture struct of my4to1LUT is

begin
	
	with ILUT select
			OLUT <= x"B400" when "0000", --aTan(2^(-0))
					x"6A43" when "00001",--aTan(2^(-1))
					x"3825" when "00010",--aTan(2^(-2))
					x"1C80" when "00011",--aTan(2^(-3))
					x"0E40" when "00100",--aTan(2^(-4))
					x"0729" when "00101",--aTan(2^(-5))
					x"0395" when "00110",--aTan(2^(-6))
					x"01CA" when "00111",--aTan(2^(-7))
					x"00E5" when "01000",--aTan(2^(-8))
					x"0073" when "01001",--aTan(2^(-9))
					x"0039" when "01010",--aTan(2^(-10))
  					x"001D" when "01011",--aTan(2^(-11))
					x"000E" when "01100",--aTan(2^(-12))
					x"0007" when "01101",--aTan(2^(-13))
					x"0004" when "01110",--aTan(2^(-14))
					x"0002" when "01111",--aTan(2^(-15))
					x"0001" when "10000",--aTan(2^(-16))
					'0' when others;

end struct;


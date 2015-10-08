----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/05/2015 02:53:11 PM
-- Design Name: 
-- Module Name: D_latch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity D_latch is
 Port (
       clk: in std_logic; 
       E:   in std_logic;
       resetn: in std_logic;
       D: in std_logic ;
       Q: out std_logic );
end D_latch;


architecture Behavioral of D_latch is

begin
process(clk,E,resetn)
begin
if resetn = '0' then
 Q <= '0';
 elsif (clk'event and clk = '1') then
 if E = '1' then
 Q <= D;
 end if;
 end if;
 end process; 
 
 

end Behavioral;






----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/07/2015 05:28:49 PM
-- Design Name: 
-- Module Name: signed_mul - Behavioral
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

entity signed_mul is
    Port ( A : in STD_LOGIC_VECTOR (11 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           S : in STD_LOGIC;
           clock : in STD_LOGIC;
           resetn : in STD_LOGIC;
           P : out STD_LOGIC_VECTOR (19 downto 0);
           done : out STD_LOGIC);
end signed_mul;

architecture Behavioral of signed_mul is

component my_addsub
		generic (N: INTEGER:= M+N);
		port(	addsub   : in std_logic;
				x, y     : in std_logic_vector (N-1 downto 0);
				s        : out std_logic_vector (N-1 downto 0);
				overflow : out std_logic;
				cout     : out std_logic);
end component;

begin


end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2015 06:26:23 PM
-- Design Name: 
-- Module Name: computation_block - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity computation_block is
  Port ( 
         start_computation : in std_logic;
         a : in std_logic_vector(7 downto 0);
         b : in std_logic_vector(7 downto 0);
         c : in std_logic_vector(7 downto 0);
         a1 : in std_logic_vector(7 downto 0);
         b1 : in std_logic_vector(7 downto 0);
         c1 : in std_logic_vector(7 downto 0);
         a2 : in std_logic_vector(7 downto 0);
         b2 : in std_logic_vector(7 downto 0);
         c2 : in std_logic_vector(7 downto 0);
         k0 : in std_logic_vector(7 downto 0);
          k1 : in std_logic_vector(7 downto 0);
          k2 : in std_logic_vector(7 downto 0);
          k3 : in std_logic_vector(7 downto 0);
          k4 : in std_logic_vector(7 downto 0);
          k5 : in std_logic_vector(7 downto 0);
          k6 : in std_logic_vector(7 downto 0);
          k7 : in std_logic_vector(7 downto 0);
          k8 : in std_logic_vector(7 downto 0);
         image: out std_logic_vector(15 downto 0)
    );
end computation_block;

architecture Behavioral of computation_block is
   
     signal A3,A4,A5,A6,A7,A8,A9,A10,A11 :std_logic_vector(15 downto 0):=(others => '0');  
begin
process (a,b,c,a1,b1,c1,a2,b2,c2,start_computation,k0,k1,k2,k3,k4,k5,k6,k7,k8)
begin
  if start_computation = '1' then
          A3 <= a*K0 ;
          A4 <= b*K3 ;
          A5 <= c*K6;
          A6 <= a1*K1 ;
          A7 <= b1*K4 ;
          A8 <= c1*K7;
          A9 <= a2*K2 ;
          A10 <= b2*K5 ;
          A11 <= c2*K8;
     image <= A3 + A4 +A5 +A6 +A7 +A8 +A9 +A10+A11 ;
          
    end if;      
end process;
end Behavioral;

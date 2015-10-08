----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/07/2015 05:50:48 PM
-- Design Name: 
-- Module Name: multi_top - Behavioral
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

entity multi_top is
  Port ( clock, resetn, s: in std_logic;
         A : in std_logic_vector (11 downto 0);
         B : in std_logic_vector (7 downto 0);
         done: out std_logic;
         P : out std_logic_vector (19 downto 0)
          );
end multi_top;

architecture Behavioral of multi_top is

component my_addsub
		generic (N: INTEGER);
		port(	addsub   : in std_logic;
				x, y     : in std_logic_vector (N-1 downto 0);
				s        : out std_logic_vector (N-1 downto 0);
				overflow : out std_logic;
				cout     : out std_logic);
	end component;

component serial_mult is
	generic (N ,M : INTEGER );
	   
	port (clock, resetn, s: in std_logic;
		  dA  : in std_logic_vector (N-1 downto 0);
		  dB  : in std_logic_vector (M-1 downto 0);
		  P   : out std_logic_vector ((M+N)-1 downto 0);
	      done: out std_logic);
end component;

component D_latch is
 Port (
       clk: in std_logic; 
       E:   in std_logic;
       resetn: in std_logic;
       D: in std_logic ;
       Q: out std_logic );
end component;

signal dA  :  std_logic_vector (11 downto 0);
signal dB  :  std_logic_vector (7 downto 0);
signal PS   :    std_logic_vector (19 downto 0);
signal dd,Qs  : std_logic ;
begin 



multiplier : serial_mult 
	generic map (N => 12,
	             M => 8)
	port map (
	       clock => clock ,
	       resetn => resetn , 
	       s => s ,
		  dA  => dA ,
		  dB  => dB ,
		  P   => ps ,
	      done => done);
addA : my_addsub generic map (N => 12)
              port map (addsub => A(11), x => x"000", y => A, s => dA);	
addB : my_addsub generic map (N => 8)
                            port map (addsub => B(7), x => x"00", y => B, s => dB); 
  dd <= A(11) xor B(7);                          
ddlatch : D_latch 
                             Port map (
                                   clk => clock , 
                                   E => s ,
                                   resetn => resetn ,
                                   D=> dd ,
                                   Q => Qs ); 
add3 : my_addsub generic map (N => 20)
                         port map (addsub => Qs, x => X"00000", y => ps, s => P);                                                                                   

end Behavioral;

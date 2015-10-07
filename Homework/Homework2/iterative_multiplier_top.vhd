----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2015 07:46:16 PM
-- Design Name: 
-- Module Name: iterative_multiplier_top - Behavioral
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

entity iterative_multiplier_top is
    generic (N:integer := 12;
             M:integer := 8); 
    Port ( A : in STD_LOGIC_VECTOR (N+M-1 downto 0);
           B : in STD_LOGIC_VECTOR (M-1 downto 0);
           clock, reset,O,L,E,EP,sclrp : in STD_LOGIC;
           P : out STD_LOGIC_VECTOR (N-1 downto 0);
           Z : out STD_LOGIC;
           b0 : out STD_LOGIC);
end iterative_multiplier_top;

architecture Behavioral of iterative_multiplier_top is

component shiftregleft is
    generic (N: INTEGER:= 12;
             DIR: STRING:= "LEFT");
    port ( clock, resetn: in std_logic;
           din, E, s_l: in std_logic; -- din: shiftin input
           D: in std_logic_vector (N-1 downto 0);
           Q: out std_logic_vector (N-1 downto 0);
           shiftout: out std_logic);   
end component;

component shiftregright is
    generic (N: INTEGER:= 12;
             DIR: STRING:= "RIGHT");
    port ( clock, resetn: in std_logic;
           din, E, s_l: in std_logic; -- din: shiftin input
           D: in std_logic_vector (N-1 downto 0);
           Q: out std_logic_vector (N-1 downto 0);
           shiftout: out std_logic);   
end component;

component nbitadder is
   generic (N:integer := 12);
   port ( a : in STD_LOGIC_VECTOR (N-1 downto 0);
          b : in STD_LOGIC_VECTOR (N-1 downto 0);
          y : out STD_LOGIC_VECTOR (N-1 downto 0));
end component;

component nbitreg is
    generic (N: INTEGER:= 12);
	port ( clock, resetn: in std_logic;
	       E, sclr: in std_logic; -- sclr: Synchronous clear
	       D: in std_logic_vector (N-1 downto 0);
	       Q: out std_logic_vector (N-1 downto 0));
end component;

    signal Qa: STD_LOGIC_VECTOR(N+M-1 downto 0);
    signal Qb: STD_LOGIC_VECTOR(M-1 downto 0);
    signal Qp: STD_LOGIC_VECTOR(N+M-1 downto 0);
    signal yD: STD_LOGIC_VECTOR(N+M-1 downto 0);
    
begin
    resetn <= not(reset);
    b0 <= Qb(N+M-1);
    z <= NOR(Qb(N+M-1 downto 0));
    shiftregA: shiftregleft port map(clock => clock, O => din, L =>s_l, E=>E, resetn => resetn, D => A, Q =>Qa); 
    shiftregB: shiftregright port map(clock => clock, O => din, L =>s_l, E=>E, resetn => resetn, D => M, Q =>Qb);
    add:  nbitadder port map(a => Qa, b =>Qp, Y => yD);
    regP: nbitreg port map(clock => clock, E=>EP, resetn => resetn, D => yD, Q =>Qp);

end Behavioral;

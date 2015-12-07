
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Grayscale_Top is
    Generic(P: integer:= 8);
    Port (RGBin: in std_logic_vector(P-1 downto 0);
          Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
          start,clock,resetn:in std_logic;
          RGBout: out std_logic_vector(P-1 downto 0);
          done: out std_logic);
end Grayscale_Top;

architecture Behavioral of Grayscale_Top is

    component Grayscale is
        generic(P: integer:=8); --P:Number of incoming Pixels
        Port(R,G,B: in std_logic_vector(P-1 downto 0);
             Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
             start,clock,resetn: in std_logic;
             RGB: out std_logic_vector(P-1 downto 0);
             done: out std_logic);
    end component Grayscale;

    signal R,G,B: std_logic_vector(P-1 downto 0);

begin
    R <= RGBin(P-1 downto P-3) & "00000";
    G <= RGBin(P-4 downto P-6) & "00000";
    B <= RGBin(P-7 downto P-8) & "000000";

    daGray: Grayscale 
        generic map(P => P) --P:Number of incoming Pixels
        port map(R => R, G => G, B =>B, Rp => Rp, Gp => Gp, Bp => Bp, start => start, clock => clock, resetn => resetn, RGB => RGBout, done =>done);

end Behavioral;

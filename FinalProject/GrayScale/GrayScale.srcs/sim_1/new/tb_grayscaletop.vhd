
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity tb_grayscaletop is
    generic(P: integer:= 8);
end tb_grayscaletop;

architecture Behavioral of tb_grayscaletop is

    component Grayscale_Top is
        Generic(P: integer:= 8);
        Port (RGBin: in std_logic_vector(P-1 downto 0);
              Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
              start,clock,resetn:in std_logic;
              RGBout: out std_logic_vector(P-1 downto 0);
              done: out std_logic);
    end component Grayscale_Top;
    
    --Inputs
    signal clock : std_logic := '0';
    signal resetn : std_logic := '0';
    signal start : std_logic := '0';
    signal RGBin: std_logic_vector(P-1 downto 0);
    signal Rp,Gp,Bp: std_logic_vector(P-1 downto 0);
    
    --Outputs
    signal RGBout: std_logic_vector(P-1 downto 0);
    signal done: std_logic;
    
       -- Clock period definitions
    constant clock_period : time := 10 ns;

begin

        gray: Grayscale_Top 
        Generic map(P => P)
        Port map(RGBin =>RGBin, Rp => Rp, Gp => Gp, Bp => Bp, start => start, clock => clock, resetn => resetn, RGBout => RGBout, done => done);
              
      -- Clock process definitions
        clock_process :process
        begin
             clock <= '0';
             wait for clock_period/2;
             clock <= '1';
             wait for clock_period/2;
        end process;     

         -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      -- resetn <= '0';
       wait for 10 ns;
       resetn <= '1';

      -- insert stimulus here 
        RGBin <= b"11111111"; Rp <= conv_std_logic_vector(100, P);	Gp <= conv_std_logic_vector(0, P); Bp <= conv_std_logic_vector(0, P); start <= '1';		
        wait for clock_period;
        start <= '0';
        wait for clock_period*25;
        
        RGBin <= b"11111111"; Rp <= conv_std_logic_vector(21, P);	Gp <= conv_std_logic_vector(72, P); Bp <= conv_std_logic_vector(7, P); start <= '1';		
        wait for clock_period;
        start <= '0';
        wait for clock_period*25;
        

   end process;

end Behavioral;
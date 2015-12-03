
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity tb_grayscale is
    generic(P: integer:= 8);
end tb_grayscale;

architecture Behavioral of tb_grayscale is

    component Grayscale is
        generic(P: integer:=8); --P:Number of incoming Pixels
        Port(R,G,B: in std_logic_vector(P-1 downto 0);
             Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
             start,clock,resetn: in std_logic;
             RGB: out std_logic_vector(P-1 downto 0);
             done: out std_logic);
    end component Grayscale;
    
    --Inputs
    signal clock : std_logic := '0';
    signal resetn : std_logic := '0';
    signal start : std_logic := '0';
    signal R,G,B: std_logic_vector(P-1 downto 0);
    signal Rp,Gp,Bp: std_logic_vector(P-1 downto 0);
    
    --Outputs
    signal RGB: std_logic_vector(P-1 downto 0);
    signal done: std_logic;
    
       -- Clock period definitions
    constant clock_period : time := 10 ns;

begin

    gray: Grayscale 
        generic map(P => P)
        Port map(R => R, G => G, B => B, Rp => Rp, Gp => Gp, Bp => Bp, start => start, clock => clock, resetn => resetn, RGB => RGB, done => done);
        
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
        R <= X"E0"; G <= X"E0"; B <= X"C0"; Rp <= conv_std_logic_vector(100, P); Gp <= conv_std_logic_vector(0, P); Bp <= conv_std_logic_vector(0, P); start <= '1';		
        wait for clock_period;
        start <= '0';
        --Result:RGB=224
        wait for clock_period*25;
        
        R <= X"E0"; G <= X"E0"; B <= X"C0"; Rp <= conv_std_logic_vector(21, P);	Gp <= conv_std_logic_vector(72, P); Bp <= conv_std_logic_vector(7, P); start <= '1';		
        wait for clock_period;
        start <= '0';
        --Result:RGB=221
        wait for clock_period*25;
        
        R <= X"10"; G <= X"80"; B <= X"40"; Rp <= conv_std_logic_vector(80, P);	Gp <= conv_std_logic_vector(10, P); Bp <= conv_std_logic_vector(10, P); start <= '1';		
        wait for clock_period;
        start <= '0';
        --Result:RGB=32
        wait for clock_period*25;

   end process;

end Behavioral;

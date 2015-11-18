----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2015 04:55:24 PM
-- Design Name: 
-- Module Name: CORDIC_Pipeline_Top - Behavioral
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


entity CORDIC_Pipeline_Top is
 generic ( N: INTEGER:= 16; --i bits
            M: INTEGER:= 16; --Z bits
            K: INTEGER:= 16); --X,Y bits
   port ( clock, reset: in std_logic;
          Xin, Yin: in std_logic_vector (K-1 downto 0);
          Zin: in std_logic_vector (M-1 downto 0);
          mode,E: in std_logic_vector(0 downto 0);
          mode_out,v: out std_logic_vector(0 downto 0);
          Xout, Yout: out std_logic_vector (K-1 downto 0);
          Zout: out std_logic_vector (M-1 downto 0)
          );
end CORDIC_Pipeline_Top;

architecture Behavioral of CORDIC_Pipeline_Top is

component CORDIC_FP_top
    generic (N: INTEGER; --number of interations (i)
             M: INTEGER:= 16; --Z bits
             K: INTEGER:= 20); --X,Y bits
	port ( clock, reset: in std_logic;
		   Xin, Yin: in std_logic_vector (K-1 downto 0);
		   Zin: in std_logic_vector (M-1 downto 0);
		   mode: in std_logic_vector(0 downto 0);
		   mode_out: out std_logic_vector(0 downto 0);
		   Xout, Yout: out std_logic_vector (K-1 downto 0);
		   Zout: out std_logic_vector (M-1 downto 0)
		   );
end component;

    component my_rege is
       generic (N: INTEGER);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic;
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component;

    --signal Xs, Ys: std_logic_vector(19 downto 0);
    signal z_out: std_logic_vector(15 downto 0);
    signal Xins, yins: std_logic_vector(19 downto 0);
    type array1 is array (integer range N-1 downto 0) of std_logic_vector(19 downto 0); 
    type array2 is array (integer range N-1 downto 0) of std_logic_vector(15 downto 0); 
    signal XS, YS : array1;
    signal ZS : array2;
    signal x_out,y_out: std_logic_vector(19 downto 0);
begin
    Xins <= x"0" & xin;
    Yins <= x"0" & yin;

 pipe: for i in 0 to 0 generate
 input: if (i = 0) generate
                XS(i) <= Xins;
                yS(i) <= Yins;
                zS(i) <= zin;
            end generate input ;
         
     other: if ((i > 0) and (i < N-1)) generate
                XS(i) <= XS(i-1);
                YS(i) <= YS(i-1);
                ZS(i) <= ZS(i-1);
            end generate other;
                            
     output: if i = N-1 generate
                x_out <= XS(i);
                y_out <= YS(i);
                z_out <= ZS(i);
             end generate output ;
             
 cordic: CORDIC_FP_top
    generic map (N => i, --number of interations (i)
             M =>16 , --Z bits
             K => 20) --X,Y bits
	port map ( clock => clock,   
	       reset=> reset,
		   Xin =>  XS(i), 
		   Yin => YS(i),
		   Zin => ZS(i) ,
		   mode => mode,
		   mode_out => mode_out,
		   Xout => XS(i) ,
		   Yout=> YS(i) ,
		   Zout => ZS(i)
		   );
 end generate pipe;
 

 
 E_reg : my_rege
        generic map(N => 1)
        port map( clock => clock, resetn => reset, E => '1', sclr => '0', D => E, Q => V);
        
 Y_reg : my_rege
      generic map(N => 16)
      port map( clock => clock, resetn => reset, E => '1', sclr => '0', D => y_out(19 downto 4), Q => Yout);  
             
 X_reg : my_rege
   generic map(N => 16)
   port map( clock => clock, resetn => reset, E => '1', sclr => '0', D => x_out(19 downto 4), Q =>Xout); 
    
    Z_reg : my_rege
     generic map(N => 16)
     port map( clock => clock, resetn => reset, E => '1', sclr => '0', D => Z_out, Q => Zout); 
end Behavioral;

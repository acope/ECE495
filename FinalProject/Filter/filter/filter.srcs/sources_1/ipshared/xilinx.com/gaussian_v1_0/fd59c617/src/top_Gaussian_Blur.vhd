----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2015 02:58:48 PM
-- Design Name: 
-- Module Name: top_Gaussian_Blur - Behavioral
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
-- fspecial('gaussian',[3,3],1)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_Gaussian_Blur is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           imaginputs : in STD_LOGIC_VECTOR (31 downto 0);
           image_out1: out std_logic_vector(15 downto 0)
         
     
   );
end top_Gaussian_Blur;

architecture Behavioral of top_Gaussian_Blur is
    TYPE RAM is array (0 to 99) of STD_LOGIC_VECTOR(7 downto 0);
    signal a,b,c : RAM := (others => (others => '0'));  
    signal convolution : std_logic:='0';
    signal imaginput :  STD_LOGIC_VECTOR (7 downto 0);
    signal start_computation : std_logic;
    signal getting_image : std_logic:='1';
    signal addra :  STD_LOGIC_VECTOR(3 DOWNTO 0):=x"0";
    signal douta :  STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE States IS (S0,S1);
    signal y : States:=S0;
    TYPE array9 is array (0 to 8) of STD_LOGIC_VECTOR(7 downto 0);
    signal Kernal : array9 := (others => (others => '0'));
    signal aa,bb,cc,a1,b1,c1,a2,b2,c2 : std_logic_vector(7 downto 0);
 component computation_block 
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
    end component;
    
--component blk_mem_gen_0 
--      PORT (
--        clka : IN STD_LOGIC;
--        ena : IN STD_LOGIC;
--        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--        addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
--        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--      );
--    END component;
component blk_mem_gen_0
 
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;  
    
begin
  process(clk, reset)
    variable j,I : integer range 0 to  99:=0;
    variable input_count : integer range 0 to  74:=0;
    begin
       if reset = '0' then
              convolution <='0';
              input_count:=0;
              getting_image <='1';
              y<= S0;
        elsif(rising_edge(clk))  then
         case y is
          when S0 =>
          if getting_image ='1' then
                    if input_count<=24 then
                           a(j)<=  imaginputs(31 downto 24);
                           a(j+1)<= imaginputs(23 downto 16);
                           a(j+2)<= imaginputs(15 downto 8);
                           a(j+3)<= imaginputs(7 downto 0);
                    
                     elsif input_count>24 and input_count<=49 then                         
                            b(j)<= imaginputs(31 downto 24);
                            b(j+1)<= imaginputs(23 downto 16);                                      
                            b(j+2)<= imaginputs(15 downto 8);                                  
                            b(j+3)<= imaginputs(7 downto 0);                                   
                                                                                                  
                     elsif input_count>49 and input_count<=74 then
                           c(j)<= imaginputs(31 downto 24);
                           c(j+1)<= imaginputs(23 downto 16);
                           c(j+2)<= imaginputs(15 downto 8);
                           c(j+3)<= imaginputs(7 downto 0);
        
                                            
                       end if;

                             
              else
                            
                            if input_count<=24 then
                                   a<= b;
                                input_count:=24 ;   
                            elsif input_count>24 and input_count<=49 then
                                   b <= c;
                                 input_count:=49 ;         
                            elsif input_count>49 and input_count<=74 then
                                  c(j)<= imaginputs(31 downto 24);
                                  c(j+1)<= imaginputs(23 downto 16);
                                  c(j+2)<= imaginputs(15 downto 8);
                                  c(j+3)<= imaginputs(7 downto 0);
                                                                                     
                              end if;
                                                                             
               end if;
                j:=j+4;
                  if input_count=24 or input_count=49 or input_count=74  then
                         j:=0;
                     end if; 
                          
             if input_count = 74 then
                input_count:=0;
                getting_image <='0'; 
                 y<=S1; 
                else
                   input_count:=input_count +1;
                   start_computation <='0'; 
                    y<=S0;
                 end if;
                 
                  
        when S1 => 
      if I<= 97 then
        aa <= a(I) ;
        bb <= b(I) ;
        cc <= c(I);
        a1 <= a(I+1);
        b1 <= b(I+1);
        c1 <= c(I+1);
        a2 <= a(I+2) ;
        b2 <= b(I+2) ;
        c2 <= c(I+2);
        start_computation <='1';  
     end if;
     if I= 97 then
        y<=S0;
        I:= 0;
        start_computation <='0';
     else
        I:= I+1;
        y<=S1;  
     end if;
       end case;              
   end if;
  end process;
   
  
    
       U0: computation_block  Port map ( 
                  start_computation => start_computation,
                  a => aa ,
                  b => bb ,
                  c => cc,
                  a1 => a1 ,
                  b1 => b1 ,
                  c1 => c1,
                  a2 => a2 ,
                  b2 => b2 ,
                  c2 => c2,
                  k0=>Kernal(0),--x"66",
                  k1=>Kernal(1),--x"73",
                  k2=>Kernal(2),--x"66",
                  k3=>Kernal(3),--x"73",
                  k4=>Kernal(4),--x"83",
                  k5=>Kernal(5),--x"73",
                  k6=>Kernal(6),--x"66",
                  k7=>Kernal(7),--x"73",
                  k8=>Kernal(8),--x"66",
                  image => image_out1
               );
               
-- U1: blk_mem_gen_2 
--                 PORT map (
--                   clka => clk,
--                   ena =>'1',
--                   addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--                   douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--                 );
 U1: blk_mem_gen_0 
  PORT map (
    clka => clk,
    ena => '1',
    addra => addra,
    douta =>douta
  );  
                                 
  process(clk)
  variable i : integer range 0 to 10:=0;
  begin
  
  if rising_edge (clk) then
  
  if i=0 then
  elsif i=1 then 
 
  elsif i=2 then 
   Kernal(i-2)<=douta;
   
  elsif i=3 then 
  Kernal(i-2)<=douta;
   
  elsif i=4 then 
   Kernal(i-2)<=douta;
   
  elsif i=5 then 
   Kernal(i-2)<=douta;
   
  elsif i=6 then 
   Kernal(i-2)<=douta;
   
   elsif i=7 then 
    Kernal(i-2)<=douta;
    
   elsif i=8 then 
     Kernal(i-2)<=douta;
     
   elsif i=9 then 
     Kernal(i-2)<=douta; 
   elsif i=10 then 
     Kernal(i-2)<=douta; 
  end if;
  i:=i+1;
  addra <=std_logic_vector(to_unsigned(i, 4));
   end if; 
  end process;       
 

end Behavioral;

 
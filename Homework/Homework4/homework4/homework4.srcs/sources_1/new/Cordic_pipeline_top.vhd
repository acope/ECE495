----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2015 01:28:20 PM
-- Design Name: 
-- Module Name: Cordic_pipeline_top - Behavioral
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

entity Cordic_pipeline_top is
    generic( N: INTEGER:= 4);
    port ( clock, reset, E, mode: in std_logic;
           Xin, Yin, Zin: in std_logic_vector (15 downto 0);
           v,mode_out: out std_logic;
           Xout, Yout, Zout: out std_logic_vector (15 downto 0)
       );
end Cordic_pipeline_top;

architecture Behavioral of Cordic_pipeline_top is

 component my_rege is
       generic (N: INTEGER);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic;
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component my_rege; 
    
     component LPM_CLSHIFT is
           generic (
               lpm_width     : natural;                               
               lpm_widthdist : natural; 
               lpm_shifttype : string := "LOGICAL";
               lpm_type      : string := "LPM_CLSHIFT";
               lpm_hint      : string := "UNUSED"
           );
           port (
               data      : in STD_LOGIC_VECTOR(lpm_width-1 downto 0); 
               distance  : in STD_LOGIC_VECTOR(lpm_widthdist-1 downto 0); 
               direction : in STD_LOGIC := '0';
               result    : out STD_LOGIC_VECTOR(lpm_width-1 downto 0);
               underflow : out STD_LOGIC;
               overflow  : out STD_LOGIC
           );
       end component LPM_CLSHIFT;
    
 signal xin_ext, yin_ext, data_X, data_Y, X, Y, result_x, result_Y, next_X, next_Y: std_logic_vector(19 downto 0);
       signal Z: std_logic_vector(15 downto 0);
       signal i: std_logic_vector(4 downto 0);
       signal di, din,resetn, as: std_logic;
       
     signal sclr : std_logic :='1';
--     signal E : std_logic :='0';
begin

    data_X_reg : my_rege
       generic map(N => 20)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => xin_ext, Q => X);
               
    data_Y_reg : my_rege
       generic map(N => 20)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => yin_ext, Q => Y);  
                 
    data_Z_reg : my_rege
       generic map(N => 16)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => zin, Q => Z); 
       
     X_barrel_shifter : LPM_CLSHIFT
             generic map(lpm_width => 20,                              
                         lpm_widthdist => 5, 
                         lpm_shifttype =>"ARITHMETIC")
                         --lpm_type      =>"LPM_CLSHIFT",
                         --lpm_hint      =>"UNUSED")
                        
             port map(data      => X, 
                      distance  => i, 
                      direction => '1',
                      result    => result_x
                      --underflow => '-',
                      --overflow  => '-');   
                      );
                      
      Y_barrel_shifter : LPM_CLSHIFT
                     generic map(lpm_width => 20,                              
                                 lpm_widthdist => 5, 
                                 lpm_shifttype =>"ARITHMETIC")
                                 --lpm_type      =>"LPM_CLSHIFT",
                                 --lpm_hint      =>"UNUSED")
                                
                     port map(data      => Y, 
                              distance  => i, 
                              direction => '1',
                              result    => result_y
                              --underflow => '-',
                              --overflow  => '-'); 
                              );   
                      



end Behavioral;

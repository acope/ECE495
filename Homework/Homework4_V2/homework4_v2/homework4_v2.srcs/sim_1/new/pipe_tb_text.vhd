----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2015 02:48:52 PM
-- Design Name: 
-- Module Name: pipe_tb_text - Behavioral
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

entity pipe_tb_text is
--  Port ( );
end pipe_tb_text;

architecture Behavioral of pipe_tb_text is


  component CORDIC_Pipeline_Top is
     generic ( N : INTEGER:= 16;
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
    end component CORDIC_Pipeline_Top;
    

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal mode,E : std_logic_vector(0 downto 0) := (others => '0');
   signal Xin : std_logic_vector(15 downto 0) := (others => '0');
   signal Yin : std_logic_vector(15 downto 0) := (others => '0');
   signal Zin : std_logic_vector(15 downto 0) := (others => '0');
   
   
   --Outputs
   signal Xout : std_logic_vector(15 downto 0) ;
   signal Yout : std_logic_vector(15 downto 0);
   signal Zout : std_logic_vector(15 downto 0) ;
   signal mode_out,V : std_logic_vector(0 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
   constant in_bench: STRING:="hw4_rotation.txt";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  cordic : CORDIC_Pipeline_Top       
        generic map(N => 16, M => 16, K => 16) 
        port map( clock => clock, 
                    reset => resetn, 
                    mode => mode,
                    Xin => Xin, 
                    Yin => Yin,
                    Zin => Zin,
                    mode_out => mode_out,
                    Xout => Xout, 
                    Yout => Yout,
                    E => E,
                    V => V,
                    Zout => Zout
                    );


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
      
       wait for 10 ns;
       resetn <= '0';
       file IN_FILE: TEXT open READ_MODE is in_bench;

      -- insert stimulus here 
		      xin <= X"0000"; yin <= X"26DC"; zin <= x"2183"; mode(0) <= '1'; E(0) <= '1'; wait for clock_period; --z = pi/6 =0x2183	
		      E(0) <= '0';
		      wait for clock_period*18; 
--		      E(0) <= '0';
--		      wait for clock_period;
		      xin <= X"0000"; yin <= X"26DC"; zin <= x"BD03"; mode(0) <= '1';E(0) <= '1'; wait for clock_period; --z = pi/6 =0x218
		      E(0) <= '0';
		      wait for clock_period*18;
--		      E(0) <= '0';
--                            wait for clock_period;
              xin <= X"3333"; yin <= X"3333"; zin <= x"0000"; mode(0) <= '0'; E(0) <= '1'; wait for clock_period; --z = pi/6 =0x218
              E(0) <= '0';
              wait for clock_period*18;
--              E(0) <= '0';
--                            wait for clock_period;
               xin <= X"2000"; yin <= X"4000"; zin <= x"0000"; mode(0) <= '0';E(0) <= '1'; wait for clock_period; --z = pi/6 =0x218
               wait for clock_period*18;
   end process;


end Behavioral;

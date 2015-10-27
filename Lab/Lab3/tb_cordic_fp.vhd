---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all; 
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_cordic_fp IS
END tb_cordic_fp;
 
ARCHITECTURE behavior OF tb_cordic_fp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)   
    component CORDIC_FP_top is
        port ( clock, reset, s, mode: in std_logic;
               Xin, Yin, Zin: in std_logic_vector (15 downto 0);
               done: out std_logic;
               Xout, Yout, Zout: out std_logic_vector (15 downto 0)
               );
    end component CORDIC_FP_top;
    

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal s : std_logic := '0';
  -- signal sclr : std_logic := '0';
   signal mode : std_logic := '0';
   signal Xin : std_logic_vector(15 downto 0) := (others => '0');
   signal Yin : std_logic_vector(15 downto 0) := (others => '0');
   signal Zin : std_logic_vector(15 downto 0) := (others => '0');
   
   
   --Outputs
   signal Xout : std_logic_vector(15 downto 0) := (others => '0');
   signal Yout : std_logic_vector(15 downto 0) := (others => '0');
   signal Zout : std_logic_vector(15 downto 0) := (others => '0');
   signal done : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  cordic : CORDIC_FP_top       
            port map( clock => clock, 
                   reset => resetn, --resetn 
                   s => s, 
                   mode => mode, 
                   Xin => Xin, 
                   Yin => Yin, 
                   Zin => Zin,
                   done => done,
                   Xout => Xout, 
                   Yout => Yout,
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
      -- hold reset state for 100 ns.
      -- resetn <= '0';
       wait for 10 ns;
       resetn <= '0';

      -- insert stimulus here 
		      xin <= X"0000"; yin <= X"26dc"; zin <= x"2183";  s <= '1'; mode <= '0'; wait for clock_period*12; --z = pi/6 = 0.5235987756 = 0x3F060A92
		      s <= '0';		
--	  wait for clock_period*(18);
--		      xin <= X"0001"; yin <= X"0001"; zin <= x"0A52";  s <= '1'; wait for clock_period; --z = -pi/3 = -1.047197551 = 0xBF860A52
--		      s <= '0';
--	  wait for clock_period*10;
--              xin <= X"0001"; yin <= X"0001"; zin <= X"0000";  s <= '1'; wait for clock_period;
--              s <= '0';
--      wait for clock_period*10;
--              xin <= x"0000"; yin <= X"0001"; zin <= X"0000";  s <= '1'; wait for clock_period; --x = 0.5 = 0x3F000000
--              s <= '0';         
      wait;
   end process;

END;

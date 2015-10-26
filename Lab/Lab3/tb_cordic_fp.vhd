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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_cordic_fp IS
END tb_cordic_fp;
 
ARCHITECTURE behavior OF tb_cordic_fp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)   
    component CORDIC_FP_top is
        port ( clock, reset, s, mode, sclr: in std_logic;
               Xin, Yin, Zin: in std_logic_vector (15 downto 0);
               done: out std_logic;
               Xout, Yout, Zout: out std_logic_vector (15 downto 0)
               );
    end component CORDIC_FP_top;
    

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal s : std_logic := '0';
   signal A : std_logic_vector(11 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal P : std_logic_vector(19 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  cordic : CORDIC_FP_top       
            port map( clock => clock, 
                   reset => not(reset), --resetn 
                   s => s, 
                   mode => mode, 
                   sclr => sclr,
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
      wait for 100 ns; reset <= '0';

      -- insert stimulus here 
		      xin <= X"0001"; yin <= X"0001"; zin <= (3.14/6);  s <= '1'; wait for clock_period;
		      s <= '0';		
		wait for clock_period*10;
		      xin <= X"0001"; yin <= X"0001"; zin <= (-3.14/3);  s <= '1'; wait for clock_period;
		      s <= '0';
		wait for clock_period*10;
              xin <= X"0001"; yin <= X"0001"; zin <= "0000";  s <= '1'; wait for clock_period;
              s <= '0';
       wait for clock_period*10;
              xin <= 0.5; yin <= X"0001"; zin <= "0000";  s <= '1'; wait for clock_period;
              s <= '0';         
      wait;
   end process;

END;

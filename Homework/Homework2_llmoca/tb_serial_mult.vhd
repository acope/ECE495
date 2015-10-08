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
 
ENTITY tb_serial_mult IS
END tb_serial_mult;
 
ARCHITECTURE behavior OF tb_serial_mult IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 component multi_top is
      Port ( clock, resetn, s: in std_logic;
             A : in std_logic_vector (11 downto 0);
             B : in std_logic_vector (7 downto 0);
             done: out std_logic;
             P : out std_logic_vector (19 downto 0)
              );
    end component;
    

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
   uut: multi_top PORT MAP (
          clock => clock,
          resetn => resetn,
          s => s,
          A => A,
          B => B,
          P => P,
          done => done
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
      wait for 100 ns; resetn <= '1';

      -- insert stimulus here 
		A <= X"FED"; B <= X"FC"; s <= '1'; wait for clock_period;
		s <= '0';
		
		wait for clock_period*10;
		A <= X"48A"; B <= X"FE"; s <= '1'; wait for clock_period;
		s <= '0';
		wait for clock_period*10;
                A <= X"78c"; B <= X"f4"; s <= '1'; wait for clock_period;
                s <= '0';
       wait for clock_period*10;
                        A <= X"78d"; B <= X"61"; s <= '1'; wait for clock_period;
                        s <= '0';         
      wait;
   end process;

END;

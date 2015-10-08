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
 
ENTITY tb_mycounter IS
END tb_mycounter;
 
ARCHITECTURE behavior OF tb_mycounter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mycounter
    PORT(
         clock : IN  std_logic;
         resetn : IN  std_logic;
         E : IN  std_logic;
         Q : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal E : std_logic := '0';

 	--Outputs
   signal Q : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant T: time := 20 ns;
 	constant DUTY_CYCLE: real:= 0.5;
	constant OFFSET: time:= 10 ns;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mycounter PORT MAP (
          clock => clock,
          resetn => resetn,
          E => E,
          Q => Q
        );

   -- Clock process definitions
   clock_process :process
   begin
		wait for OFFSET;
		clock_loop: loop
			clock <= '0'; wait for (T - (T*DUTY_CYCLE));
			clock <= '1'; wait for (T*DUTY_CYCLE);
		end loop clock_loop;
   end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for OFFSET;	

      resetn <= '0'; wait for T*5;
      -- insert stimulus here 
		resetn <= '0';
        E <= '1'; resetn <= '0'; wait for T*2;
        --E <= '1'; resetn <= '1'; wait for T/2;
        E <= '1'; resetn <= '1'; wait for T*5;
        E <= '0'; wait for T*2;
        E <= '1';

      wait;
   end process;

END;

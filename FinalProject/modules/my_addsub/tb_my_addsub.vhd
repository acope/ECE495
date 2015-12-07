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
use ieee.std_logic_arith.all;
 
ENTITY tb_my_addsub IS
	generic (N: INTEGER:= 4);
END tb_my_addsub;
 
ARCHITECTURE behavior OF tb_my_addsub IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_addsub
    PORT(
         addsub : IN  std_logic;
         x : IN  std_logic_vector(N-1 downto 0);
         y : IN  std_logic_vector(N-1 downto 0);
         s : OUT  std_logic_vector(N-1 downto 0);
         overflow : OUT  std_logic;
         cout : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal addsub : std_logic := '0';
   signal x : std_logic_vector(N-1 downto 0) := (others => '0');
   signal y : std_logic_vector(N-1 downto 0) := (others => '0');

 	--Outputs
   signal s : std_logic_vector(N-1 downto 0);
   signal overflow : std_logic;
   signal cout : std_logic;
    
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_addsub PORT MAP (
          addsub => addsub,
          x => x,
          y => y,
          s => s,
          overflow => overflow,
          cout => cout
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		-- insert stimulus here 
--		addsub <= '0'; -- Addition operation
--		x <= x"F"; y <= x"F"; wait for 20 ns;
--		x <= x"7"; y <= x"2"; wait for 20 ns;
--		x <= x"8"; y <= x"3"; wait for 20 ns;
--		x <= x"A"; y <= x"C"; wait for 20 ns;
--		x <= x"B"; y <= x"4"; wait for 20 ns;
--		x <= x"0"; y <= x"0"; wait for 20 ns;
--		
--		addsub <= '1'; -- Subtraction operation
--		x <= x"1"; y <= x"F"; wait for 20 ns;
--		x <= x"A"; y <= x"2"; wait for 20 ns;
--		x <= x"C"; y <= x"E"; wait for 20 ns;
--		x <= x"1"; y <= x"8"; wait for 20 ns;
--		x <= x"6"; y <= x"1"; wait for 20 ns;
--		x <= x"0"; y <= x"0"; wait for 20 ns;
		
		addsub <= '0'; -- Addition operation
		bi: for i in 0 to 2**N -1 loop
					y <= conv_std_logic_vector(i, N);
					bj: for j in 0 to 2**N -1 loop
							x <= conv_std_logic_vector(j, N); wait for 10 ns;
						 end loop;
			 end loop;

		addsub <= '1'; -- Subtraction operation
		xi: for i in 0 to 2**N -1 loop
					y <= conv_std_logic_vector(i, N);
					xj: for j in 0 to 2**N -1 loop
							x <= conv_std_logic_vector(j, N); wait for 10 ns;
						 end loop;
			 end loop;
      
      wait;
   end process;

END;

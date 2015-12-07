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

ENTITY tb_my_mult IS
	generic (N: INTEGER:= 4);
END tb_my_mult;
 
ARCHITECTURE behavior OF tb_my_mult IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_mult
    PORT(
         A : IN  std_logic_vector(N-1 downto 0);
         B : IN  std_logic_vector(N-1 downto 0);
         P : OUT  std_logic_vector(2*N-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(N-1 downto 0) := (others => '0');
   signal B : std_logic_vector(N-1 downto 0) := (others => '0');

 	--Outputs
   signal P : std_logic_vector(2*N-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_mult PORT MAP (
          A => A,
          B => B,
          P => P
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
      -- insert stimulus here 
		A <= conv_std_logic_vector(3,N);  B <= conv_std_logic_vector (15,N); wait for 20 ns;
		A <= conv_std_logic_vector(14,N); B <= conv_std_logic_vector (10,N); wait for 20 ns;
		A <= conv_std_logic_vector(10,N); B <= conv_std_logic_vector (15,N); wait for 20 ns;
		A <= conv_std_logic_vector(8,N);  B <= conv_std_logic_vector (13,N); wait for 20 ns;
		A <= conv_std_logic_vector(10,N); B <= conv_std_logic_vector (12,N); wait for 20 ns;
		A <= conv_std_logic_vector(2**N -1,N); B <= conv_std_logic_vector (2**N -1,N); wait for 20 ns;
		A <= conv_std_logic_vector(0,N); B <= conv_std_logic_vector (0,N); wait for 20 ns;
		
      wait;
   end process;

END;

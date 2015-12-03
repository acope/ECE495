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
  
ENTITY tb_my_busmux4to1 IS
	generic (N: INTEGER:= 8);
END tb_my_busmux4to1;
 
ARCHITECTURE behavior OF tb_my_busmux4to1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT my_busmux4to1
    PORT(
         a : IN  std_logic_vector(N-1 downto 0);
         b : IN  std_logic_vector(N-1 downto 0);
         c : IN  std_logic_vector(N-1 downto 0);
         d : IN  std_logic_vector(N-1 downto 0);
         s : IN  std_logic_vector(1 downto 0);
         y_r : OUT  std_logic_vector(N-1 downto 0);
         y_t : OUT  std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(N-1 downto 0) := (others => '0');
   signal b : std_logic_vector(N-1 downto 0) := (others => '0');
   signal c : std_logic_vector(N-1 downto 0) := (others => '0');
   signal d : std_logic_vector(N-1 downto 0) := (others => '0');
   signal s : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal y_r : std_logic_vector(N-1 downto 0);
   signal y_t : std_logic_vector(N-1 downto 0);
    
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_busmux4to1 PORT MAP (
          a => a,
          b => b,
          c => c,
          d => d,
          s => s,
          y_r => y_r,
          y_t => y_t
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		s <= "00"; a <= x"28"; b <= x"AB"; c <= x"BF"; d <= x"E0"; wait for 20 ns;
		s <= "01"; a <= x"C6"; b <= x"A7"; c <= x"FF"; d <= x"E6"; wait for 20 ns;
		s <= "10"; a <= x"29"; b <= x"7B"; c <= x"0F"; d <= x"5B"; wait for 20 ns;
		s <= "11"; a <= x"3D"; b <= x"CB"; c <= x"F1"; d <= x"44"; wait for 20 ns;
		s <= "00"; a <= x"00"; b <= x"00"; c <= x"00"; d <= x"00";
      wait;
   end process;

END;

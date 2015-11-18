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
        generic (N: INTEGER:= 16; --number of interations (i)
                M: INTEGER:= 16; --Z bits
                K: INTEGER:= 20); --X,Y bits
       port ( clock, reset: in std_logic;
              Xin, Yin: in std_logic_vector (K-1 downto 0);
              Zin: in std_logic_vector (M-1 downto 0);
              mode: in std_logic_vector(0 downto 0);
              mode_out: out std_logic_vector(0 downto 0);
              Xout, Yout: out std_logic_vector (K-1 downto 0);
              Zout: out std_logic_vector (M-1 downto 0)
              );
    end component CORDIC_FP_top;
    

   --Inputs
   signal clock : std_logic := '0';
   signal resetn : std_logic := '0';
   signal mode : std_logic_vector(0 downto 0) := (others => '0');
   signal Xin : std_logic_vector(19 downto 0) := (others => '0');
   signal Yin : std_logic_vector(19 downto 0) := (others => '0');
   signal Zin : std_logic_vector(15 downto 0) := (others => '0');
   
   
   --Outputs
   signal Xout : std_logic_vector(19 downto 0) := (others => '0');
   signal Yout : std_logic_vector(19 downto 0) := (others => '0');
   signal Zout : std_logic_vector(15 downto 0) := (others => '0');
   signal mode_out : std_logic_vector(0 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  cordic : CORDIC_FP_top       
        generic map(N => 0, M => 16, K => 20) 
        port map( clock => clock, 
                    reset => resetn, 
                    mode => mode,
                    Xin => Xin, 
                    Yin => Yin,
                    Zin => Zin,
                    mode_out => mode_out,
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
		      xin <= X"00000"; yin <= X"026DC"; zin <= x"2183"; mode(0) <= '1'; wait for clock_period; --z = pi/6 =0x2183	
   end process;

END;

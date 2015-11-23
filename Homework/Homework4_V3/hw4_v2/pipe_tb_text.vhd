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
use STD.textio.all;
use ieee.std_logic_textio.all;

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
  -- constant in_bench: STRING:="hw4_rotation.txt";
    file file_VECTORS : text;
    file X_RESULTS : text;
    file Z_RESULTS : text;
    file Y_RESULTS : text;
    
 
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
      variable v_ILINE     : line;
      variable v_OLINE     : line;
      variable v_ADD_TERM1 : std_logic_vector(15 downto 0);
     -- variable v_ADD_TERM2 : std_logic_vector(c_WIDTH-1 downto 0);
      variable v_SPACE     : character;
   begin
   
    file_open(file_VECTORS, "C:\Users\mr_co_000\Desktop\hw4_v2\hw4_v2\hw4_vectoring.txt",  read_mode);
    file_open(X_RESULTS, "output2_X_N16.txt", write_mode);
    file_open(Y_RESULTS, "output2_Y_N16.txt", write_mode);
    file_open(Z_RESULTS, "output2_Z_N16.txt", write_mode);		
      
       wait for 10 ns;
       resetn <= '0';
      -- file IN_FILE: TEXT open READ_MODE is in_bench;

      -- insert stimulus here 
       while not endfile(file_VECTORS) loop
           readline(file_VECTORS, v_ILINE);
           read(v_ILINE, v_ADD_TERM1);
           read(v_ILINE, v_SPACE);           -- read in the space character
         --  read(v_ILINE, v_ADD_TERM2);
     
           -- Pass the variable to a signal to allow the ripple-carry to use it
           
          -- r_ADD_TERM2 <= v_ADD_TERM2;
           xin <=v_ADD_TERM1; yin <= X"4000";Zin <=x"0000" ; mode(0) <= '0'; E(0) <= '1'; wait for clock_period; --z = pi/6 =0x2183	
           E(0) <= '0';
           wait for clock_period*18; 
     
         --  wait for 60 ns;
     
           write(v_OLINE, Zout, right, 16);
           writeline(Z_RESULTS, v_OLINE);
           write(v_OLINE, Xout, right, 16);
           writeline(X_RESULTS, v_OLINE);
           write(v_OLINE, Yout, right, 16);
           writeline(Y_RESULTS, v_OLINE);
         end loop;
     
         file_close(file_VECTORS);
         file_close(X_RESULTS);
         file_close(Y_RESULTS);
         file_close(Z_RESULTS);
		     

   end process;


end Behavioral;

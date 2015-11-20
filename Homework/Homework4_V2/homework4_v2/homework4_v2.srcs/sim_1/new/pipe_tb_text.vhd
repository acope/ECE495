LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;

entity pipe_tb_text is
	generic (N : INTEGER:= 16; --iteration
             M: INTEGER:= 16; --Z bits
             K: INTEGER:= 16); --X,Y bits); --Length of file
end pipe_tb_text;

architecture Behavioral of pipe_tb_text is


  component CORDIC_Pipeline_Top is
     generic ( N : INTEGER:= N;
              M: INTEGER:= M; --Z bits
              K: INTEGER:= K); --X,Y bits
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
   signal mode: std_logic_vector(0 downto 0) := (others => '0');
   signal E : std_logic_vector(0 downto 0) := (others => '0');
   signal Xin : std_logic_vector(15 downto 0) := (others => '0');
   signal Yin : std_logic_vector(15 downto 0) := (others => '0');
   signal Zin : std_logic_vector(15 downto 0) := (others => '0');
  
  
   --Outputs
   signal Xout : std_logic_vector(K-1 downto 0) ;
   signal Yout : std_logic_vector(K-1 downto 0);
   signal Zout : std_logic_vector(M-1 downto 0) ;
   signal mode_out,V : std_logic_vector(0 downto 0);

	constant in_bench: STRING:="hw4_rotation.txt";
   -- Clock period definitions
	constant PERIOD: time:= 20 ns; -- 50 MHz clock
	constant DUTY_CYCLE: real:= 0.5;
	constant OFFSET: time:= 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
  cordic : CORDIC_Pipeline_Top       
        --generic map(N => N, M => M, K => K) 
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
	-- Clock Process Definition
	ck: process
		 begin
			wait for OFFSET; -- Wait 100 ns for global reset to finish
			clock_loop: loop -- loop that defines the PLB_clock
				clock <= '0';
				wait for (PERIOD - (PERIOD*DUTY_CYCLE));
				clock <= '1';				
				wait for (PERIOD*DUTY_CYCLE);
			end loop clock_loop;
		 end process;




 stim_proc: process
        file IN_FILE: TEXT open READ_MODE is in_bench;
        variable BUFI: line;
        variable VAR: std_logic_vector (M-1 downto 0);
   begin		

		--resetn <= '0';
      wait for OFFSET; resetn <= '1';	
	  wait for 3*PERIOD; resetn <= '0';
	  E(0) <= '1'; 
              l_tb: loop
                       exit l_tb when endfile(IN_FILE);
                       readline (IN_FILE, BUFI);
                       read (BUFI, var); -- can also use hread is you know that data is multiple of 4.
                       lcp: for i in 0 to 0 loop             
                                mode(0) <= '1';       
                                Xin <= X"0000"; 
                                Yin <= X"26DC"; 
                                Zin((i+1)*M -1 downto i*M) <= var;                                                  
                           end loop;          
                       wait for PERIOD;
                     end loop;      
                   
                  
            wait;
   end process;
   
   tb_o: process
            file OUT_FILE: TEXT open WRITE_MODE is "hw4_rotation16_out.txt";
            variable BUFO: line;
            variable OVAR: std_logic_vector (K+K+M -1 downto 0);
          begin
            lp: loop
                  wait until v(0) = '1' and (clock'event and clock='1');
                  OVAR:= Xout & Yout & Zout; 
                  write(BUFO, OVAR); --use hwrite if you know it's gonna work!
                  writeline(OUT_FILE, BUFO);
                  wait for PERIOD;
              end loop;
                     
          end process;



end Behavioral;

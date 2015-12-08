
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;


entity tb_grayscale_textfile is
    generic(P: integer:= 8);
end tb_grayscale_textfile;

architecture Behavioral of tb_grayscale_textfile is


    component Grayscale_Top is
        Generic(P: integer:= 8);
        Port (RGBin: in std_logic_vector(P-1 downto 0);
              Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
              start,clock,resetn:in std_logic;
              RGBout: out std_logic_vector(P-1 downto 0);
              done: out std_logic);
    end component Grayscale_Top;
    

    --Inputs
    signal clock : std_logic := '0';
    signal resetn : std_logic := '0';
    signal start : std_logic := '0';
    signal RGBin: std_logic_vector(P-1 downto 0);
    signal Rp,Gp,Bp: std_logic_vector(P-1 downto 0);
    
    --Outputs
    signal RGBout: std_logic_vector(P-1 downto 0);
    signal done: std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
  -- constant in_bench: STRING:="hw4_rotation.txt";
    file file_PIXELS : text;
     file RGBout_RESULTS : text;
    
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    gray: Grayscale_Top 
    Generic map(P => P)
    Port map(RGBin =>RGBin, Rp => Rp, Gp => Gp, Bp => Bp, start => start, clock => clock, resetn => resetn, RGBout => RGBout, done => done);


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
      variable v_ADD_TERM1 : std_logic_vector(7 downto 0);
     -- variable v_ADD_TERM2 : std_logic_vector(c_WIDTH-1 downto 0);
      variable v_SPACE     : character;
   begin
   
    file_open(file_PIXELS, "C:\Users\mr_co_000\Desktop\grayscaleExamp2.txt",  read_mode);
    file_open(RGBout_RESULTS, "GrayscaleTest.txt", write_mode);	
      
       wait for 10 ns;
       resetn <= '0';
      -- file IN_FILE: TEXT open READ_MODE is in_bench;

      -- insert stimulus here 
       while not endfile(file_PIXELS) loop
           readline(file_PIXELS, v_ILINE);
           read(v_ILINE, v_ADD_TERM1);
           read(v_ILINE, v_SPACE);           -- read in the space character
           
           RGBin <= v_ADD_TERM1; Rp <= conv_std_logic_vector(50, P); Gp <= conv_std_logic_vector(25, P); Bp <= conv_std_logic_vector(25, P); start <= '1';		
           wait for clock_period;
           start <= '0';
           wait for clock_period*25;
     
         --  wait for 60 ns;
     
           write(v_OLINE, RGBout, right, 16);
           writeline(RGBout_RESULTS, v_OLINE);
         end loop;
     
         file_close(file_PIXELS);
         file_close(RGBout_RESULTS);

		     

   end process;


end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

entity test is
	generic ( NC: INTEGER:= 1; -- number of cores (NI-to-NO LUTs)
			  NI: INTEGER:= 8;
			  NO: INTEGER:= 12;
			  USE_PRIM: STRING:= "NO"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
			  -- "YES" does not seem to work
	port (   clock, resetn: in std_logic;
	         E: in std_logic;
			 dyn_in:  in std_logic_vector(NC*NI - 1 downto 0);
			 dyn_outOA: out std_logic_vector(NC*NO - 1 downto 0);
			 dyn_outOB: out std_logic_vector(NC*NO - 1 downto 0);
			 dyn_outOC: out std_logic_vector(NC*NO - 1 downto 0);
			 v: out std_logic);	
end test;

architecture structure of test is
	
	constant file_LUT: STRING:= "LUT_values"&integer'image(NI)&"to"&integer'image(NO)&".txt";		
	constant F: INTEGER:= 1;	
   -- Type of function (1..5):
	-- Function 1: Gamma correction - 0.5
	-- Function 2: Gamma correction - 2
	-- Function 3: Inverse Gamma correction - 0.5
	-- Function 4: Inverse Gamma correction - 2
	-- Function 5: Contrast Stretching - Alpha = 2, m = 0.5
	-- ....
	signal dyn_out1, dyn_out2, dyn_out3 : std_logic_vector(NC*NO - 1 downto 0);	
	signal dyn_in1, dyn_in2, dyn_in3  : std_logic_vector(NC*NI - 1 downto 0);
	
	signal va: std_logic;
	
begin

-- Input register
	process (clock, resetn, E, dyn_in)
	begin
		if resetn = '0' then
			dyn_in1 <= (others => '0');
			va <= '0';
		elsif (clock'event and clock = '1') then
		    if E = '1' then
		    	dyn_in1 <= dyn_in;
		    	va <= '1';
		    end if;
		end if;
	end process;
	
	process (clock, resetn, E, dyn_in)
    begin
        if resetn = '0' then
            dyn_in2 <= (others => '0');
            va <= '0';
        elsif (clock'event and clock = '1') then
            if E = '1' then
                dyn_in2 <= dyn_in;
                va <= '1';
            end if;
        end if;
    end process;
    
    process (clock, resetn, E, dyn_in)
    begin
        if resetn = '0' then
            dyn_in3 <= (others => '0');
            va <= '0';
        elsif (clock'event and clock = '1') then
            if E = '1' then
                dyn_in3 <= dyn_in;
                va <= '1';
            end if;
        end if;
    end process;

	process (clock, resetn, va)
	begin
		if resetn = '0' then
			v <= '0';
		elsif (clock'event and clock = '1') then
		    if va = '1' then
		    	v <= '1';
		    end if;
		end if;
	end process;
	
-- Output register
	process (clock, resetn, dyn_out1)
	begin
		if resetn = '0' then
			dyn_outOA <= (others => '0');
		elsif (clock'event and clock = '1') then
			dyn_outOA <= dyn_out1;
		end if;
	end process;
	
		process (clock, resetn, dyn_out2)
    begin
        if resetn = '0' then
            dyn_outOB <= (others => '0');
        elsif (clock'event and clock = '1') then
            dyn_outOB <= dyn_out2;
        end if;
    end process;
    
    	process (clock, resetn, dyn_out3)
    begin
        if resetn = '0' then
            dyn_outOC <= (others => '0');
        elsif (clock'event and clock = '1') then
            dyn_outOC <= dyn_out3;
        end if;
    end process;
	
	
	
-- dyn_in, dyn_out are std_logic_vectors because EDK has problems with custom data types
fL: LUT_group generic map (NC, NI, NO, F, USE_PRIM, file_LUT)
	 port map (dyn_in => dyn_in1, dyn_out => dyn_out1);
	 
gL: LUT_group generic map (NC, NI, NO, F*2, USE_PRIM, file_LUT)
     port map (dyn_in => dyn_in2, dyn_out => dyn_out2);	
          
hL: LUT_group generic map (NC, NI, NO, F*3, USE_PRIM, file_LUT)
     port map (dyn_in => dyn_in3, dyn_out => dyn_out3);           
	 
end structure;


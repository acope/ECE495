
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.LPM_COMPONENTS.all;

--library work;
--use work.pack_xtras.all;

entity CORDIC_FP_top is
    generic (N: INTEGER; --number of interations (i)
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
end CORDIC_FP_top;

architecture Behavioral of CORDIC_FP_top is
   
    component my_rege is
       generic (N: INTEGER);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic;
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component my_rege;
    
    component my4to1LUT is
        port ( ILUT: in std_logic_vector (4 downto 0);
               OLUT: out std_logic_vector (15 downto 0));
    end component my4to1LUT;
    
    component mux_2to1 is
        Port ( SEL : in  STD_LOGIC_VECTOR(0 downto 0);
               A   : in  STD_LOGIC;
               B   : in  STD_LOGIC;
               X   : out STD_LOGIC);
    end component mux_2to1;
    
    component my_addsub is
        generic (N: INTEGER);
        port(addsub   : in std_logic;
             x, y     : in std_logic_vector (N-1 downto 0);
             s        : out std_logic_vector (N-1 downto 0);
             overflow : out std_logic;
             cout     : out std_logic);
    end component my_addsub;
    
    component LPM_CLSHIFT is
        generic (
            lpm_width     : natural;                               
            lpm_widthdist : natural; 
            lpm_shifttype : string := "LOGICAL";
            lpm_type      : string := "LPM_CLSHIFT";
            lpm_hint      : string := "UNUSED"
        );
        port (
            data      : in STD_LOGIC_VECTOR(lpm_width-1 downto 0); 
            distance  : in STD_LOGIC_VECTOR(lpm_widthdist-1 downto 0); 
            direction : in STD_LOGIC := '0';
            result    : out STD_LOGIC_VECTOR(lpm_width-1 downto 0);
            underflow : out STD_LOGIC;
            overflow  : out STD_LOGIC
        );
    end component LPM_CLSHIFT;
    
    component my_pashiftreg is
       generic (N: INTEGER:= 4;
                DIR: STRING:= "LEFT");
        port ( clock, resetn: in std_logic;
               din, E, s_l: in std_logic; -- din: shiftin input
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
               shiftout: out std_logic);
    end component my_pashiftreg;
    
    signal resetn: std_logic;
    signal din, di,yn,zdi: std_logic;
    signal E: std_logic := '1'; --Pernament enable??? #FIXME
    signal sclr: std_logic := '0'; --Pernament sclr??? #FIXME
    signal Z, result_z,e_i: std_logic_vector(M-1 downto 0);
    signal X,Y, result_y, result_x: std_logic_vector(K-1 downto 0);
    signal modes: std_logic_vector(0 downto 0);
    --signal PARAM_i: std_logic_vector(4 downto 0); --LUT value from aTan table
begin
    
    resetn <= not(reset);
    din <= not(di);
    yn <= not(y(K-1)); --MSB and invert to go into mode mux
    zdi <= z(M-1);
    mode_out <= modes;
--------------------------------------------------------------------------------------
--MUX PORT MAP------------------------------------------------------------------------
--------------------------------------------------------------------------------------    
    muxDI :mux_2to1
        port map( SEL => modes, A => zdi, B => yn, X => di);

--------------------------------------------------------------------------------------
--REGISTER PORT MAP-------------------------------------------------------------------
--------------------------------------------------------------------------------------  
                                          
    data_X_reg : my_rege
       generic map(N => K)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => Xin, Q => X);
               
    data_Y_reg : my_rege
          generic map(N => K)
          port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => Yin, Q => Y);  
                 
    data_Z_reg : my_rege
       generic map(N => M)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => Zin, Q => Z); 
       
          mode_reg : my_rege
           generic map(N => 1)
           port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => mode, Q => modes); 
--	mode_reg: my_pashiftreg 
--	   generic map (N => ceil_log2(N), DIR => "RIGHT")
--       port map (clock => clock, resetn => resetn, din => mode, E => '1', s_l => '0', D => (others => '0'), shiftout => modes);
              
--------------------------------------------------------------------------------------
--ADD/SUB PORT MAP--------------------------------------------------------------------
--------------------------------------------------------------------------------------  
    X_addsub : my_addsub
        generic map(N => K)
        port map(addsub => din, x => x, y => result_y, s => xout);--overflow => 'U',--cout => 'U' );
             
    Y_addsub : my_addsub
         generic map(N => K)
         port map(addsub => di,x => y, y => result_x, s => yout);--overflow => 'U',-- cout => 'U'););
    Z_addsub : my_addsub
         generic map(N => M)
         port map(addsub => din, x => Z, y => e_i, s => zout);-- overflow => 'U',--cout => 'U'););
--------------------------------------------------------------------------------------
--LUT ARCTAN PORT MAP-----------------------------------------------------------------
--------------------------------------------------------------------------------------  
    n0: if N = 0 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00000", OLUT => e_i);
                
            X_barrel_shifter : LPM_CLSHIFT
            generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
            port map(data => X, distance => "00000", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
             generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
             port map(data => Y, distance  => "00000", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;  
    n1: if N = 1 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00001", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00001", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00001", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate; 
    n2: if N = 2 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00010", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00010", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00010", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;             
            
    n3: if N = 3 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00011", OLUT => e_i);
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00011", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00011", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;             
            
    n4: if N = 4 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00100", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00100", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00100", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;             
            
    n5: if N = 5 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00101", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00101", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00101", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate; 
                            
    n6: if N = 6 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00110", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00110", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00110", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                                                         
                            
    n7: if N = 7 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "00111", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "00111", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "00111", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                             
                   
    n8: if N = 8 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01000", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01000", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01000", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                                                        
                            
    n9: if N = 9 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01001", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01001", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01001", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                             
                            
                            
    n10: if N = 10 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01010", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01010", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01010", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                             
                            
    n11: if N = 11 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01011", OLUT => e_i);
            
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01011", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01011", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                             
                            
    n12: if N = 12 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01100", OLUT => e_i);
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01100", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01100", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate; 
                                                        
    n13: if N = 13 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01101", OLUT => e_i);
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01101", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01101", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                                                         
                                                        
    n14: if N = 14 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01110", OLUT => e_i);
                X_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
               port map(data => X, distance => "01110", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
               port map(data => Y, distance  => "01110", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;                                                                                                 
    n15: if N = 15 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "01111", OLUT => e_i);
                
            X_barrel_shifter : LPM_CLSHIFT
            generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
            port map(data => X, distance => "01111", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                        
             Y_barrel_shifter : LPM_CLSHIFT
             generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
             port map(data => Y, distance  => "01111", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate; 
    n16: if N = 16 generate
            LUT_aTan : my4to1LUT
            port map( ILUT => "10000", OLUT => e_i);
                
            X_barrel_shifter : LPM_CLSHIFT
            generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
            port map(data => X, distance => "10000", direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                    
            Y_barrel_shifter : LPM_CLSHIFT
            generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
            port map(data => Y, distance  => "10000", direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
        end generate;             


--    LUT_aTan : my4to1LUT
--       port map( ILUT => PARAM_i(conv_integer(N)), OLUT => e_i);     
                 
--------------------------------------------------------------------------------------
--BARREL SHIFTER PORT MAP-------------------------------------------------------------
--------------------------------------------------------------------------------------           
     
--    X_barrel_shifter : LPM_CLSHIFT
--       generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")            
--       port map(data => X, distance => PARAM_i(conv_integer(N)), direction => '1', result => result_x); --underflow => '-',--overflow  => '-');   );
                
--     Y_barrel_shifter : LPM_CLSHIFT
--       generic map(lpm_width => K, lpm_widthdist => 5, lpm_shifttype =>"ARITHMETIC")--lpm_type      =>"LPM_CLSHIFT",--lpm_hint      =>"UNUSED")          
--       port map(data => Y, distance  => PARAM_i(conv_integer(N)), direction => '1',result => result_y);--underflow => '-',--overflow  => '-'); );   
               

    
end Behavioral;
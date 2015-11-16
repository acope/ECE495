
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.LPM_COMPONENTS.all;

entity CORDIC_FP_top is
    generic( N: INTEGER:= 16);
	port ( clock, reset, E, mode: in std_logic;
		   Xin, Yin, Zin: in std_logic_vector (15 downto 0);
		   v,mode_out: out std_logic;
		   X_out, Y_out, Z_out: out std_logic_vector (15 downto 0)
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
        Port ( SEL : in  STD_LOGIC;
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
    

   type array1 is array (integer range N-1 downto 0) of std_logic_vector(19 downto 0); 
     signal XS,YS,data_X, data_Y, X, Y, result_x, result_Y, next_X, next_Y: array1;
   type array2 is array (integer range N-1 downto 0) of std_logic_vector(15 downto 0); 
     signal ZS,Z, next_z,e_i: array2; 
   type array3 is array (integer range N-1 downto 0) of std_logic; 
     signal di, din,yn: array3;   

    signal resetn: std_logic;
    
  signal sclr : std_logic :='1';
begin

    resetn <= not(reset);
  -- XS(0) <= (others=>'0');
  -- YS(0) <= (others=>'0');
  -- ZS(0) <= (others=>'0');
 test: for i in 0 to N-1 generate 

    yn(i) <= not(y(i)(19));
    din(i) <= not(di(i));
 
        input: if (i = 0) generate
               XS(0) <= xin& x"0";
               yS(0) <= yin& x"0";
               zS(0) <= zin;
        end generate input ;
        
      none:  if ((i>0) and (i<N-1)) generate
                       --E <= E;
                        XS(i) <= next_x(i);
                        YS(i) <= next_y(i);
                        ZS(i) <= next_z(i);
            end generate none;
            
                 
       output:  if i = N-1 generate
               v <= E;
               x_out <= next_x(i)(19 downto 4);
               y_out <= next_y(i)(19 downto 4);
               z_out <= next_z(i);
               mode_out <= mode;
          end generate output ;         
          
--------------------------------------------------------------------------------------
--MUX PORT MAP------------------------------------------------------------------------
-------------------------------------------------------------------------------------- 
          
    mux_di :mux_2to1      
        port map( SEL => mode, A => z(i)(15), B => yn(i), X => di(i));
               
 
--------------------------------------------------------------------------------------
--REGISTER PORT MAP-------------------------------------------------------------------
--------------------------------------------------------------------------------------  
                                          
    data_X_reg : my_rege
       generic map(N => 20)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => XS(i), Q => X(i));
               
    data_Y_reg : my_rege
       generic map(N => 20)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => YS(i), Q => Y(i));  
                 
    data_Z_reg : my_rege
       generic map(N => 16)
       port map( clock => clock, resetn => resetn, E => E, sclr => sclr, D => ZS(i), Q => Z(i)); 
        
              
--------------------------------------------------------------------------------------
--ADD/SUB PORT MAP--------------------------------------------------------------------
--------------------------------------------------------------------------------------  
    X_addsub : my_addsub
        generic map(N => 20)
        port map(addsub => din(i), x => x(i), y => result_y(i), s => next_x(i)); --overflow => 'U', cout => 'U'
                         
    Y_addsub : my_addsub
         generic map(N => 20)
         port map(addsub => di(i), x => y(i), y => result_x(i), s => next_y(i)); --overflow => 'U', cout => 'U');
              
    Z_addsub : my_addsub
         generic map(N => 16)
         port map(addsub => din(i), x => Z(i), y => e_i(i), s => next_z(i)); -- overflow => 'U', cout => 'U');
                
--------------------------------------------------------------------------------------
--LUT ARCTAN PORT MAP-----------------------------------------------------------------
--------------------------------------------------------------------------------------  

    LUT_aTan : my4to1LUT
       port map( ILUT => conv_std_logic_vector(i,5),
                 OLUT => e_i(i));     
                 
--------------------------------------------------------------------------------------
--BARREL SHIFTER PORT MAP-------------------------------------------------------------
--------------------------------------------------------------------------------------           
     
    X_barrel_shifter : LPM_CLSHIFT
       generic map(lpm_width => 20,                              
                   lpm_widthdist => 5, 
                   lpm_shifttype =>"ARITHMETIC")
                   --lpm_type      =>"LPM_CLSHIFT",
                   --lpm_hint      =>"UNUSED")
                  
       port map(data      => X(i), 
                distance  => conv_std_logic_vector(i,5), 
                direction => '1',
                result    => result_x(i)
                --underflow => '-',
                --overflow  => '-');   
                );
                
     Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => 20,                              
                           lpm_widthdist => 5, 
                           lpm_shifttype =>"ARITHMETIC")
                           --lpm_type      =>"LPM_CLSHIFT",
                           --lpm_hint      =>"UNUSED")
                          
               port map(data      => Y(i), 
                        distance  => conv_std_logic_vector(i,5), 
                        direction => '1',
                        result    => result_y(i)
                        --underflow => '-',
                        --overflow  => '-'); 
                        );   
 end generate test;


end Behavioral;
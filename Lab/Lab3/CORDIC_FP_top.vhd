
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity CORDIC_FP_top is
	port ( clock, reset, s, mode: in std_logic;
		   Xin, Yin, Zin: in std_logic_vector (15 downto 0);
		   done: out std_logic;
		   Xout, Yout, Zout: out std_logic_vector (15 downto 0)
		   );
end CORDIC_FP_top;

architecture Behavioral of CORDIC_FP_top is
   
    component my_rege is
       generic (N: INTEGER);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic; -- sclr: Synchronous clear
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component my_rege;
    
    component my4to1LUT is
        port ( ILUT: in std_logic_vector (4 downto 0);
               OLUT: out std_logic);
    end component my4to1LUT;
    
    component mux_2to1 is
        generic (N: INTEGER:=2);
        Port ( SEL : in  STD_LOGIC;
               A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
               B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
               X   : out STD_LOGIC_VECTOR (N-1 downto 0));
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
    
    signal xin_ext, yin_ext, data_X, data_Y, X, Y, result, next_X, next_Y: std_logic_vector(19 downto 0);
    signal data_Z, next_Z, Z: std_logic_vector(15 downto 0);
    signal s_xyz, di, E, i, resetn: std_logic_vector;
  
begin

    xin_ext <= xin & x"0";
    yin_ext <= yin & x"0"; 
    resetn <= not(reset);
--------------------------------------------------------------------------------------
--MUX PORT MAP------------------------------------------------------------------------
--------------------------------------------------------------------------------------    
    muxX :mux_2to1
        generic map (N => 2)
        port map( SEL => s_xyz,
                 A  => xin_ext,
                 B  => next_X,
                 X  => data_x);
               
   muxY :mux_2to1
        generic map (N => 2)
        port map( SEL => s_xyz,
                 A  => yin_ext,
                 B  => next_Y,
                 X  => data_y);
              
   muxZ :mux_2to1
        generic map (N => 2)
        port map( SEL => s_xyz,
                 A  => Zin,
                 B  => next_Z,
                 X  => data_Z);
 
--------------------------------------------------------------------------------------
--REGISTER PORT MAP-------------------------------------------------------------------
--------------------------------------------------------------------------------------  
                                          
   data_X_reg : my_rege
       generic map(N => 19)
       port map( clock => clock, 
                 resetn => resetn,
                 E => E, 
                 sclr => sclr,
                 D => data_x,
                 Q => X);
               
    data_Y_reg : my_rege
          generic map(N => 19)
          port map( clock => clock, 
                 resetn => resetn,
                 E => E, 
                 sclr => sclr,
                 D => data_y,
                 Q => Y);  
                 
     data_Z_reg : my_rege
       generic map(N => 15)
       port map( clock => clock, 
              resetn => resetn,
              E => E, 
              sclr => sclr,
              D => data_Z,
              Q => Z); 
              
--------------------------------------------------------------------------------------
--ADD/SUB PORT MAP--------------------------------------------------------------------
--------------------------------------------------------------------------------------                         
        

end Behavioral;
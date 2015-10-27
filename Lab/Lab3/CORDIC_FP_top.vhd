
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.LPM_COMPONENTS.all;

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
               E, sclr: in std_logic;
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component my_rege;
    
    component my4to1LUT is
        port ( ILUT: in std_logic_vector (4 downto 0);
               OLUT: out std_logic_vector (15 downto 0));
    end component my4to1LUT;
    
    component mux_2to1 is
        generic (N: INTEGER);
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
    
    type state is (S1, S2, S3);
    signal state_y: state:=S1;
    signal xin_ext, yin_ext, data_X, data_Y, X, Y, result_x, result_Y, next_X, next_Y: std_logic_vector(19 downto 0);
    signal data_Z, next_Z, Z, e_i: std_logic_vector(15 downto 0);
    signal i: std_logic_vector(4 downto 0);
    signal s_xyz, di, resetn : std_logic;
    
  signal sclr : std_logic :='1';
  signal E : std_logic :='0';
begin

    xin_ext <= xin & x"0";
    yin_ext <= yin & x"0"; 
    resetn <= not(reset);
--------------------------------------------------------------------------------------
--MUX PORT MAP------------------------------------------------------------------------
--------------------------------------------------------------------------------------    
    muxX :mux_2to1
        generic map (N => 20)
        port map( SEL => s_xyz,
                 A  => xin_ext,
                 B  => next_X,
                 X  => data_x);
               
    muxY :mux_2to1
        generic map (N => 20)
        port map( SEL => s_xyz,
                 A  => yin_ext,
                 B  => next_Y,
                 X  => data_y);
              
    muxZ :mux_2to1
        generic map (N => 16)
        port map( SEL => s_xyz,
                 A  => Zin,
                 B  => next_Z,
                 X  => data_Z);
 
--------------------------------------------------------------------------------------
--REGISTER PORT MAP-------------------------------------------------------------------
--------------------------------------------------------------------------------------  
                                          
    data_X_reg : my_rege
       generic map(N => 20)
       port map( clock => clock, 
                 resetn => resetn,
                 E => E, 
                 sclr => sclr,
                 D => data_x,
                 Q => X);
               
    data_Y_reg : my_rege
          generic map(N => 20)
          port map( clock => clock, 
                 resetn => resetn,
                 E => E, 
                 sclr => sclr,
                 D => data_y,
                 Q => Y);  
                 
    data_Z_reg : my_rege
       generic map(N => 16)
       port map( clock => clock, 
              resetn => resetn,
              E => E, 
              sclr => sclr,
              D => data_Z,
              Q => Z); 
              
--------------------------------------------------------------------------------------
--ADD/SUB PORT MAP--------------------------------------------------------------------
--------------------------------------------------------------------------------------  
    X_addsub : my_addsub
        generic map(N => 20)
        port map(addsub => not(di),
             x => x,
             y => result_y,     
             s => next_x
             --overflow => 'U',
             --cout => 'U'
             );
             
    Y_addsub : my_addsub
         generic map(N => 20)
         port map(addsub => di,
              x => y,
              y => result_x,     
              s => next_Y
              --overflow => 'U',
             -- cout => 'U');
              );
    Z_addsub : my_addsub
         generic map(N => 16)
         port map(addsub => not(di),
              x => Z,
              y => e_i,     
              s => next_Z
             -- overflow => 'U',
              --cout => 'U');
                );
--------------------------------------------------------------------------------------
--LUT ARCTAN PORT MAP-----------------------------------------------------------------
--------------------------------------------------------------------------------------  

    LUT_aTan : my4to1LUT
       port map( ILUT => i,
                 OLUT => e_i);     
                 
--------------------------------------------------------------------------------------
--BARREL SHIFTER PORT MAP-------------------------------------------------------------
--------------------------------------------------------------------------------------           
     
    X_barrel_shifter : LPM_CLSHIFT
       generic map(lpm_width => 20,                              
                   lpm_widthdist => 5, 
                   lpm_shifttype =>"ARITHMETIC")
                   --lpm_type      =>"LPM_CLSHIFT",
                   --lpm_hint      =>"UNUSED")
                  
       port map(data      => X, 
                distance  => i, 
                direction => '1',
                result    => result_x
                --underflow => '-',
                --overflow  => '-');   
                );
                
     Y_barrel_shifter : LPM_CLSHIFT
               generic map(lpm_width => 20,                              
                           lpm_widthdist => 5, 
                           lpm_shifttype =>"ARITHMETIC")
                           --lpm_type      =>"LPM_CLSHIFT",
                           --lpm_hint      =>"UNUSED")
                          
               port map(data      => Y, 
                        distance  => i, 
                        direction => '1',
                        result    => result_y
                        --underflow => '-',
                        --overflow  => '-'); 
                        );   
                
--------------------------------------------------------------------------------------
--OUT SIGNALS-------------------------------------------------------------------------
-------------------------------------------------------------------------------------- 
    Xout <= X(19 downto 4);
    Yout <= Y(19 downto 4);
    Zout <= Z;
    
--------------------------------------------------------------------------------------
--FINITE STATE MACHINE----------------------------------------------------------------
-------------------------------------------------------------------------------------- 
    
    
    Transitions: process (resetn, clock, s,i)
    begin
            if resetn = '0' then -- asynchronous signal
                state_y <= S1; -- if resetn asserted, go to initial state: S1
                
            elsif (clock'event and clock = '1') then  
                if state_y = s2 then
                end if;
                case state_y is
                    when S1 =>  if s = '1' then state_y <= S2;  end if;
                    when S2 =>  if i = "01111" then state_y <= S3; else state_y <= S2; end if;
                    when S3 => if s = '1' then state_y <= S3; else state_y <= S1; end if;
                end case;
            end if;
    end process;
    
    Outputs: process (state_y,mode,Z(15),Y(19))
    begin
         -- Initialization of output signals
        done <= '0'; E <= '0'; sclr <= '0';
        case state_y is
            when S1 =>
                 E <= '1';
                 s_xyz <= '1';                
                 i <= "00000";
            when S2 =>
                E <= '1';
               s_xyz <= '0';
               i <= i + 1;
                
                
                if mode = '0' then
                    di <= Z(15);
                end if;
                
                if mode = '1' then
                    di <= Y(19);
                end if;
                
            when S3 => 
             i <= "00000";
            done <= '1';
            E <= '1';
            sclr <= '1';
        end case;
    end process;
    
end Behavioral;
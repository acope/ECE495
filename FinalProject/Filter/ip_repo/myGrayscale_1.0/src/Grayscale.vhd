library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;


entity Grayscale is
    generic(P: integer:=8); --P:Number of incoming Pixels
    Port(R,G,B: in std_logic_vector(P-1 downto 0);
         Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
         start,clock,resetn: in std_logic;
         RGB: out std_logic_vector(P-1 downto 0);
         done: out std_logic);
end Grayscale;

architecture Behavioral of Grayscale is
    
    component my_mult
       generic (N: INTEGER:= 8);
        port (A,B: in std_logic_vector (N-1 downto 0);
              P: out std_logic_vector (2*N-1 downto 0));
    end component my_mult;
    
    component my_addsub 
        generic (N: INTEGER:= 16);
        port(addsub   : in std_logic;
             x, y     : in std_logic_vector (N-1 downto 0);
             s        : out std_logic_vector (N-1 downto 0);
             overflow : out std_logic;
             cout     : out std_logic);
    end component my_addsub;

    component my_busmux3to1
       generic (N: INTEGER:= 8); -- Length of each input signal
        port (a,b,c: in std_logic_vector (N-1 downto 0);
              s: in std_logic_vector (1 downto 0);
              y: out std_logic_vector (N-1 downto 0));
    end component my_busmux3to1;
    
    component res_div_iter is
        generic (N: INTEGER:= 8; -- N >= M
                 M: INTEGER:= 4);
        port( DA: in std_logic_vector(N-1 downto 0);
              DB: in std_logic_vector(M-1 downto 0);
              clock, resetn: in std_logic;
              E: in std_logic;
              Q: out std_logic_vector (N-1 downto 0);
              R: out std_logic_vector(M-1 downto 0);
              done: out std_logic);
    end component res_div_iter;
    
     component my_rege
       generic (N: INTEGER:= 4);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic; -- sclr: Synchronous clear
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component;

    signal RGBc, RGBp, divR,divendend: std_logic_vector(P-1 downto 0);
    signal RGBmul,RGBmuls,RGBadd,RGBaddreg,divQ: std_logic_vector(2*P-1 downto 0);
    signal s: std_logic_vector (1 downto 0);
    signal overflow, cout, Ea, Ed,Em, Eout, divdone,grayclr: std_logic;
    signal C : integer range 0 to 3;
    signal DIVCONST: integer:=100;
   
   	type state is (S1, S2, S3);
    signal ys: state;

begin
    s <= conv_std_logic_vector(C, 2);       
    
    
    RGBcolormux: my_busmux3to1
       generic map(N => P)
       port map(a => R, b => G, c => B, s => s, y => RGBc);
        
    RGBpercentmux: my_busmux3to1
       generic map(N => P) 
       port map(a => Rp, b => Gp, c => Bp, s => s, y => RGBp); 
       
    mul: my_mult
       generic map(N => P)
       port map(A => RGBc, B => RGBp, P => RGBmul);  
       
  
--    mulReg: my_rege 
--       generic map (N => 2*P)
--       port map (clock => clock, resetn => resetn, E => Em, sclr => grayclr, D => RGBmul, Q => RGBmuls); 

 
    RGBmuls <= RGBmul when Em='1' else (others => '0');     
        
    adder: my_addsub 
       generic map(N => 2*P)
       port map(addsub => '0', x => RGBmuls, y => RGBaddreg, s => RGBadd, overflow => overflow, cout => cout);
       
    addReg: my_rege 
       generic map (N => 2*P)
       port map (clock => clock, resetn => resetn, E => '1', sclr => grayclr, D => RGBadd, Q => RGBaddreg);    
     
    -- Iterative Divider: A/B: A = Q*B + R  
    --DIVCONST <= 100; 
    divendend <= conv_std_logic_vector(DIVCONST,8);
    divider: res_div_iter 
       generic map(N => 2*P, M => P)
       port map( DA => RGBaddreg, DB => divendend, clock => clock, resetn => resetn, E => Ed, Q => divQ, R => divR, done => divdone);
           
    RGB <= divQ(P-1 downto 0);
    
--    outReg: my_rege 
--       generic map (N => P)
--       port map (clock => clock, resetn => resetn, E => Eout, sclr => '0', D => divQ(P-1 downto 0), Q => RGB);         


--FSM
    Transitions: process (resetn, clock)
        begin
            if resetn = '0' then
                ys <= S1;
            elsif (clock'event and clock = '1') then
                case ys is
                    when S1 =>
                        C <= 0;
                        if start = '1' then
                            ys <=S2;
                        else
                            ys <= S1;
                        end if;                                
                    when S2 =>
                        if C = 3 then
                            C <= 0;
                            ys <= S3;
                        else
                            C <= C + 1;
                            ys <= S2;
                        end if;
                    when S3 =>
                        if divdone = '1' then
                            ys <= S1;
                        else
                            ys <= S3;
                        end if;    
                end case;
            end if;	
        end process;
        
        Outputs: process (ys, Ea, Ed,Em,C, divdone,grayclr)
        begin
            -- Initialization of output signals
            Ea <= '0'; Ed <= '0'; Em <= '0';  done <= '0'; grayclr <= '0';--Eout <= '0';
            case ys is
                when S1 =>
                    grayclr <= '1';
                    done <= '0';
                when S2 =>
                    Ea <= '1';
                    Em <= '1';
                    if C = 3 then
                        Ed <= '1';
                    else 
                        Ed <= '0';
                    end if;    
                when S3 =>
                     grayclr <= '1';
                    if divdone = '1' then
                        done <= '1';
                    else
                        done <= '0';    
                    end if;
            end case;
        end process;


end Behavioral;

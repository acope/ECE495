
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cordic_ip is
	port (	clock: in std_logic;
            rst: in std_logic; -- high-level reset                
            DI: in std_logic_vector (31 downto 0);
            DO: out std_logic_vector (31 downto 0);
            ofull, iempty: in std_logic;
            owren, irden: out std_logic);    
end cordic_ip;

architecture Behavioral of cordic_ip is

       component CORDIC_FP_top 
            port ( clock, reset, s, mode: in std_logic;
                   Xin, Yin, Zin: in std_logic_vector (15 downto 0);
                   done: out std_logic;
                   Xout, Yout, Zout: out std_logic_vector (15 downto 0)
                   );
        end component;
        
        component my_rege is
           generic (N: INTEGER);
            port ( clock, resetn: in std_logic;
                   E, sclr: in std_logic;
                   D: in std_logic_vector (N-1 downto 0);
                   Q: out std_logic_vector (N-1 downto 0));
        end component my_rege;
        
        component mux_2to1 is
            generic (N: INTEGER);
            Port ( SEL : in  STD_LOGIC;
                   A   : in  STD_LOGIC_VECTOR (N-1 downto 0);
                   B   : in  STD_LOGIC_VECTOR (N-1 downto 0);
                   X   : out STD_LOGIC_VECTOR (N-1 downto 0));
        end component mux_2to1;
        

    signal QOO,DD: STD_LOGIC_VECtOR(63 downto 0);
    signal QOI,QOO_XY,QOO_Z: STD_LOGIC_VECTOR(31 downto 0);
    signal Xin, Yin, Zin: STD_LOGIC_VECTOR(15 downto 0);
    signal Xout, Yout, Zout: STD_LOGIC_VECTOR(15 downto 0);
    signal resetn,done,mode,Eri,Ebuff,s,start: std_logic;
    signal C, T : integer range 0 to 3;
    signal irden_t: std_logic;
    
    signal CO: std_logic;
    type state is (S1, S2, S3, S4);	
    signal y,ys: state :=S1; 
    
begin

resetn <= not(rst);
s <= CO; --From Output FSM

irden <= irden_t;
--Input Interface
        --Eri: Controls the Register
        --DO: Register Input 32 bits
        --QOI: Register Output 32 bits, splits off into 2 different signals to to to CORDIC;
        II_Reg:my_rege generic map (N => 32)
                       port map (clock => clock, resetn => resetn, E => Eri, sclr => '0', D => DI, Q => QOI);
         
       --Interconnecting Signals
       Xin <= QOI(31 downto 16);
       Yin <= QOI(15 downto 0);                
       Zin <= DI(31 downto 16);
       mode <= DI(15);                
                       
--CORDIC
	   CORDIC: CORDIC_FP_top 
          port map( clock => clock, reset => rst, s => start, mode => mode, Xin => Xin, Yin => Yin, Zin => Zin, done => done, Xout => Xout, Yout => Yout, Zout => Zout); 
                                   
                       
--Output Interface 
        --Ebuff: Controls the Register
        --DOO:  Register Input 64 bits, takes the output from CORDIC(X,Y,Z)
        --QOO: Register Output 64 bits, Splits off into 2 different signals to go to the mux 
          DD<= Xout & Yout & Zout & x"0000" ;              
        OI_Reg:my_rege generic map (N => 64)
                       port map (clock => clock, resetn => resetn, E => Ebuff, sclr => '0', D =>DD , Q => QOO);
                       

        --Interconnecting Signals                        
        QOO_XY <= QOO(63 downto 32);
        QOO_Z <= QOO(31 downto 0);               
                       
        OI_Mux :mux_2to1
                        generic map (N => 32)
                        port map( SEL => s, A  => QOO_Z, B  => QOO_XY, X  => DO);
                        
--Input FSM    
        Transitions: process (resetn, clock)
		begin
		    
		    if resetn = '0' then
               y <= S1;
               C <= 0; T <= 0;
			elsif (clock'event and clock = '1') then
				case y is
					when S1 =>
					     C <= 0; T <= 0;
                        if iempty = '0' then
                            y <= S1;
                        else
                            y <= S2;
                        end if;
					when S2 =>
					   if iempty = '0' and ofull = '0' then
					       if C = 1 then
					           C <= 0;
					           y <= S3;
					       else
					           C <= C + 1;
					           y <= S2;
					       end if;    
					   else
					       y <= S2;
					   end if;
					when S3 =>
					   if done = '1' then
					       y <= S4;
					       
					   else
					       y <= S3;
					   end if;
					when S4 =>
					   if T = 3 then
					       T <= 0;
					       y <= S2;
					   else
					       T <= T + 1;
					       y <= S4;
					   end if;

							
				end case;
			end if;
		end process;
				
		Outputs: process (y, C, done ,iempty,ofull)
		begin
		start <= '0'; irden_t <= '0';
			case y is
				when S1 =>
                    start <= '0';
				when S2 =>
				    if iempty = '0' and ofull = '0' then
				        irden_t <= '1';
                        if C = 1 then
                            --C <= '0';
                            start <= '1';
                        else
                            --C <= '1';
                            --Eri <= '0';
                        end if;   
                    
                    end if;
                when S3 =>
                    if done = '1' then
                        start <= '0';
                    end if;        
				when S4 =>
--                    if T = 3 then
--                        T <= 0;
--                    else
--                       T <= T+1;         
--                     end if;
                when others => 
				end case;		
		end process; 

Eri <= '1' when (C=0 and irden_t='1') else '0';

--Output FSM
		Transitions1: process (resetn, clock)
		begin
			if resetn = '0' then
				ys <= S1; CO <= '0';
			elsif (clock'event and clock = '1') then
				case ys is
					when S1 =>
					    CO <= '0';
						if done = '1' then 
						    ys <= S1; 
						else 
						    ys <= S2; 
						end if;
					when S2 =>
						if done = '1' then	
							ys <= S3;
						else
							ys <= S2;
						end if;
					when S3 =>
						if CO = '1' then
						    CO <= '0';
							ys <= S2; 
						else
						    CO <= '1';
							ys <= S3;
						end if;
				when others => 			
				end case;
			end if;
		end process;
				
		Outputs1: process (ys, done)
		begin
			-- Initialization of signals
		    owren <= '0'; Ebuff <= '0';
			case ys is
				when S1 =>
					--CO <= '0';
				when S2 =>
					if done = '1' then
						Ebuff <= '1';				
					end if;
				when S3 =>
					owren <= '1';
--					if CO = '1' then
--						CO <= '0';				
--					else
--						CO <= '1'; -- CO <= CO + 1
--					end if;
				when others => 	
				end case;		
		end process; 
 
end Behavioral;

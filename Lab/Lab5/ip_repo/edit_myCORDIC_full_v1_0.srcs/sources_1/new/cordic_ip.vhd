
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
        
        component my_counter is
        --    generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
            generic (COUNT: INTEGER:= 20); -- 
            port (clock, resetn: in std_logic;
                  clk_en: in std_logic; -- clk_en = 1 -> all the other synchronous pins work!
                    cnt_en, sclr: in std_logic; -- sclr = 1 -> Q = 0, cnt_en = 1 -> Q <= Q+1
                    Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
                    z: out std_logic); -- z = 1 when the maximum count (COUNT-1) has been reached
        end component my_counter;

    signal QOO: STD_LOGIC_VECtOR(63 downto 0);
    signal QOI,QOO_XY,QOO_Z: STD_LOGIC_VECTOR(31 downto 0);
    signal Xin, Yin, Zin: STD_LOGIC_VECTOR(15 downto 0);
    signal Xout, Yout, Zout: STD_LOGIC_VECTOR(15 downto 0);
    signal resetn,done,mode,Eri,Ebuff,s,start: std_logic;
    signal CO,C: STD_LOGIC;
    
    type state is (S1, S2, S3, S4);	
    signal y,ys: state; 
    
begin

resetn <= not(rst);
s <= CO; --From Output FSM

--    if C = '0' and irden = '1' then
--        Eri <= '1';
--    else
--        Eri <= '0';
--    end if;
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
        OI_Reg:my_rege generic map (N => 64)
                       port map (clock => clock, resetn => resetn, E => Ebuff, sclr => '0', D => Xout & Yout & Zout & x"0000", Q => QOO);
                       

        --Interconnecting Signals                        
        QOO_XY <= QOO(63 downto 32);
        QOO_Z <= QOO(31 downto 0);               
                       
        OI_Mux :mux_2to1
                        generic map (N => 32)
                        port map( SEL => s, A  => QOO_Z, B  => QOO_XY, X  => DO);
                        
--Input FSM    
        Transitions: process (rst, clock)
		begin
			if rst = '1' then
				y <= S1;
			elsif (clock'event and clock = '1') then
				case y is
					when S1 =>
                        if iempty = '0' then
                            y <= S1;
                        else
                            y <= S2;
                        end if;
					when S2 =>
					   if iempty = '0' and ofull = '0' then
					       if C ='1' then
					           y <= S3;
					       else
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
					   if T = "3" then
					       y <= S2;
					   else
					       y <= S4;
					   end if;

							
				end case;
			end if;
		end process;
				
		Outputs: process (y, C, T, done)
		begin
			case y is
				when S1 =>
                    C <= '0';
                    T <= '0';
				when S2 =>
				    if iempty = '0' and ofull = '0' then
				        irden <= '1';
                        if C ='1' then
                            C <= '0';
                            start <= '1';
                        else
                            C <= '1';
                        end if;    
                    end if;
				when S4 =>
                    if T = "3" then
                        T <= 0;
                    else
                       T := T+1; --#FIXME not the right way to do palce holder
                       
                     end if;
				end case;		
		end process; 

--        cC: my_counter generic map (COUNT => 3)
--            port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_C, sclr => sclr_C, Q => C, z => cout_C);


--Output FSM
		Transitions: process (rst, clock)
		begin
			if rst = '1' then
				ys <= S1;
			elsif (clock'event and clock = '1') then
				case ys is
					when S1 =>
						if done = '1' then 
						    ys <= S1; 
						else 
						    ys <= S2; 
						end if;
					when S2 =>
						if done = '1' then
							Ebuff <= '1';
							ys <= S3;
						else
							ys <= S2;
						end if;
					when S3 =>
						if CO = '1' then
							ys <= S2; 
						else
							ys <= S3;
						end if;
							
				end case;
			end if;
		end process;
				
		Outputs: process (ys, CO, done)
		begin
			-- Initialization of signals
		    owren <= '0'; Ebuff <= '0';
			case ys is
				when S1 =>
					CO <= 0;
				when S2 =>
					if done = '1' then
						Ebuff <= '1';				
					end if;
				when S3 =>
					owren <= '1';
					if CO = '1' then
						CO <= '0';				
					else
						CO <= '1'; -- CO <= CO + 1
					end if;
				end case;		
		end process; 
 
end Behavioral;

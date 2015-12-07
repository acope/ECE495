---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2014).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

library work;
use work.pack_xtras.all;

-- Iterative Divider: A/B: A = Q*B + R
-- Latency: N cycles
-- It divides positive integers represented as unsigned
-- The case B=0 should NOT be allowed (include a flag later)
--     A/0: --> Q = 11...1, R = A(M-1 downto 0)
entity res_div_iter is
	generic (N: INTEGER:= 8; -- N >= M
	         M: INTEGER:= 4);
	port( DA: in std_logic_vector(N-1 downto 0);
		  DB: in std_logic_vector(M-1 downto 0);
		  clock, resetn: in std_logic;
		  E: in std_logic;
          Q: out std_logic_vector (N-1 downto 0);
		  R: out std_logic_vector(M-1 downto 0);
		  done: out std_logic);
end res_div_iter;

architecture structure of res_div_iter is

    component my_rege
       generic (N: INTEGER:= 4);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic; -- sclr: Synchronous clear
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component;

    component my_pashiftreg
       generic (N: INTEGER:= 4;
                 DIR: STRING:= "LEFT");
        port ( clock, resetn: in std_logic;
               din, E, s_l: in std_logic; -- din: shiftin input
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
              shiftout: out std_logic);
    end component;

    component my_pashiftreg_sclr
       generic (N: INTEGER:= 4;
                 DIR: STRING:= "LEFT");
        port ( clock, resetn: in std_logic;
               din, E, s_l, sclr: in std_logic; -- din: shiftin input
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
              shiftout: out std_logic);
    end component;

    component my_counter
        generic (COUNT: INTEGER:= 20); -- 
        port (clock, resetn: in std_logic;
              clk_en: in std_logic; -- clk_en = 1 -> all the other synchronous pins work!
                cnt_en, sclr: in std_logic; -- sclr = 1 -> Q = 0, cnt_en = 1 -> Q <= Q+1
                Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
                z: out std_logic); -- z = 1 when the maximum count (COUNT-1) has been reached
    end component;

	component my_sub -- subtraction with cin
		generic (N: INTEGER:= 4);
		port(	x, y     : in std_logic_vector (N-1 downto 0);
				cin      : in std_logic:='1'; -- cin = 1 by default (this allows for a proper subtraction of x-y)
				s        : out std_logic_vector (N-1 downto 0);
				overflow : out std_logic;
				cout     : out std_logic);
	end component;
		
	signal A: std_logic_vector (N-1 downto 0);
	signal B, Rt: std_logic_vector (M-1 downto 0);
	
	signal Y, YN, xB: std_logic_vector (M downto 0);
	signal LAB, EA, LR, ER, sclrR, rst, cout: std_logic;
	
	type state is (S1, S2, S3);
	signal ys: state;

	signal EC, sclrC: std_logic;
	
	signal C: std_logic_vector ( integer(ceil(log2(real(N))))-1 downto 0);
	
begin

a1: assert (N >= M)
    report "Error: N can not be lower than M!!!"
    severity error;
	 
	Transitions: process (resetn, clock, E,C)
	begin
		if resetn = '0' then
			ys <= S1;
		elsif (clock'event and clock = '1') then
			case ys is
				when S1 =>
					if E = '1' then ys <= S2; else ys <= S1; end if;
												
				when S2 =>
					if C = conv_std_logic_vector(N-1, ceil_log2(N)) then -- C = N-1 ?
						ys <= S3;
					else
						ys <= S2;
					end if;
					
				when S3 =>
					if E = '1' then ys <= S3; else ys <= S1; end if;

			end case;
		end if;	
	end process;
	
	Outputs: process (ys, cout, E, C)
	begin
		-- Initialization of output signals
		EC <= '0'; sclrC <= '0'; ER <= '0'; sclrR <= '0'; LR <= '0'; done <= '0';
		LAB <= '0'; EA <= '0';
		
		case ys is
			when S1 =>
				sclrR <= '1'; ER <= '1'; -- clear shift register R
				sclrC <= '1'; -- C <= 0
				if E = '1' then
					LAB <= '1'; EA <= '1';
				end if;
				
			when S2 =>
				ER <= '1'; EA <= '1';
				if cout = '1' then LR <= '1'; end if;
				if C /= conv_std_logic_vector(N-1, ceil_log2(N)) then -- C = N-1 ?
					EC <= '1'; -- C <= C + 1
				end if;
			
			when S3 =>
				done <= '1';
				
		end case;
	end process;
	
--cC: lpm_counter generic map (LPM_WIDTH => ceil_log2(N), LPM_DIRECTION => "UP")
--	 port map (clock => clock, cnt_en => EC, aclr => rst, sclr => sclrC, q => C);
--    rst <= not (resetn);
    
cC: my_counter generic map (COUNT => N)
    port map (clock => clock, resetn => resetn, clk_en =>  '1', cnt_en => EC, sclr => sclrC, Q => C);

--gA: lpm_shiftreg generic map (lpm_width => N, lpm_direction => "LEFT")
--    port map (clock => clock, data => DA, load => LAB, enable => EA, shiftin => cout, aclr => rst, q => A);
gA: my_pashiftreg generic map (N => N, DIR => "LEFT")
    port map (clock => clock, resetn => resetn, din => cout, E => EA, s_l => LAB, D => DA, Q => A);
        	  
--gB: lpm_ff generic map (LPM_WIDTH => M)
--	 port map (data => DB, clock => clock, q => B, enable => LAB, aclr => rst, aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0');	 
gB: my_rege generic map (N => M)
    port map (clock => clock, resetn => resetn, E => LAB, sclr => '0', D => DB, Q => B);	      
     
  	 xB <= '0'&B;
	 Y <= Rt&A(N-1);

sb: my_sub generic map (N => M+1)
    port map (x => Y, y => xB, cin => '1', s => YN, cout => cout);

--gR: lpm_shiftreg generic map (lpm_width => M, lpm_direction => "LEFT")
--    port map (clock => clock, data => YN(M-1 downto 0), load => LR, enable => ER, sclr => sclrR, shiftin => A(N-1), aclr => rst, q => Rt);	 
gR: my_pashiftreg_sclr generic map (N => M, DIR => "LEFT")
    port map (clock => clock, resetn => resetn, din => A(N-1), E => ER, s_l => LR, sclr => sclrR, D => YN(M-1 downto 0), Q => Rt);    
    
	 R <= Rt;
	 Q <= A;
		 
end structure;

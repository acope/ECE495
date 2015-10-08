---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity serial_mult is
	generic (N: INTEGER:= 12;
	         M: INTEGER:= 8);
	port (clock, resetn, s: in std_logic;
		  dA  : in std_logic_vector (N-1 downto 0);
		  dB  : in std_logic_vector (M-1 downto 0);
		  P   : out std_logic_vector ((M+N)-1 downto 0);
	      done: out std_logic);
end serial_mult;

architecture Behavioral of serial_mult is

	component shiftregleft
		generic (N: INTEGER:= N+M;
                 DIR: STRING:= "LEFT");
        port ( clock, resetn: in std_logic;
               din, E, s_l: in std_logic; -- din: shiftin input
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
               shiftout: out std_logic);
	end component;
	
	component shiftregright
        generic (N: INTEGER:= M;
                 DIR: STRING:= "RIGHT");
        port ( clock, resetn: in std_logic;
               din, E, s_l: in std_logic; -- din: shiftin input
               D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
               shiftout: out std_logic);
    end component;
	
	component my_addsub
		generic (N: INTEGER:= M+N);
		port(	addsub   : in std_logic;
				x, y     : in std_logic_vector (N-1 downto 0);
				s        : out std_logic_vector (N-1 downto 0);
				overflow : out std_logic;
				cout     : out std_logic);
	end component;
	
	component my_rege
		generic (N: INTEGER:= M+N);
		port ( clock, resetn: in std_logic;
				 E, sclr: in std_logic; -- sclr: Synchronous clear
				 D: in std_logic_vector (N-1 downto 0);
				 Q: out std_logic_vector (N-1 downto 0));
	end component;

	type state is (S1, S2, S3);
	signal y: state;
	
	signal LA, LB, EA, EB, EP, sclrP, z: std_logic;
	signal B: std_logic_vector (M-1 downto 0);
	signal A, dAx, dP, Pt: std_logic_vector (M+N-1 downto 0);
	
begin

rA: shiftregleft generic map (N => N+M, DIR => "LEFT")
    port map (clock => clock, resetn => resetn, din => '0', s_l => LA, E => EA, D => dAx, Q => A);
	 dAx ((M+N)-1 downto N) <= (others =>'0');
	 dAx (N-1 downto 0) <= dA;

rB: shiftregright generic map (N => M, DIR => "RIGHT")
    port map (clock => clock, resetn => resetn, din => '0', s_l => LB, E => EB, D => dB, Q => B);
	 
-- n-bit NOR gate:
	process (B)
		variable result_or: std_logic;
	begin
		result_or:= '0';
		for i in B'range loop -- 'range: iterates through all bits in 'A'
			result_or := result_or or B(i);
		end loop;		
		z <= not (result_or);
	end process;
	 
--	 Adder:
ga: my_addsub generic map (N => M+N)
    port map (addsub => '0', x => A, y => Pt, s => dP);
	 
-- Register P:
rP: my_rege generic map (N => M+N)
	 port map (clock => clock, resetn => resetn, E => EP, sclr => sclrP, D => dP, Q => Pt);
	 
	 P <= Pt;

-- FSM:
	Transitions: process (resetn, clock, s, z, B(0))
	begin
		if resetn = '0' then -- asynchronous signal
			y <= S1; -- if resetn asserted, go to initial state: S1			
		elsif (clock'event and clock = '1') then
			case y is
				when S1 => if s = '1' then y <= S2; else y <= S1; end if;
				when S2 => if z = '1' then y <= S3; else y <= S2; end if;
				when S3 => if s = '1' then y <= S3; else y <= S1; end if;
			end case;
		end if;
	end process;
	
	Outputs: process (y, s,z,B(0))
	begin
	   -- Initialization of output signals
		sclrP <= '0'; EP <= '0'; LA <= '0'; LB <= '0'; EA <= '0'; EB <= '0'; done <= '0';
		case y is
			when S1 => 
					sclrP <= '1'; EP <= '1';
					if s = '1' then
						LA <= '1'; EA <= '1';
						LB <= '1'; EB <= '1';
					end if;
			
			when S2 =>
				EA <= '1'; EB <= '1';
				if z = '0' then
					if B(0) = '1' then EP <= '1'; end if;
				end if;
				
			when S3 =>
				done <= '1';
		end case;
	end process;
	
end Behavioral;


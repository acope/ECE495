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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pack_xtras.all;

-- This is very similar to 'fsm_fullypip'. The only difference is that 
-- we include a state in the FSM (called 'SW') where we wait for N-2 cycles.
entity fsm_onetrans is
	generic (NWIC: INTEGER:= 1;
				NWOC: INTEGER:= 1;
				N: INTEGER:=8);
	port (	clock: in std_logic;
				rst: in std_logic; -- high-level reset
				iempty, ofull: in std_logic;
				Eri: out std_logic_vector (NWIC-2 downto 0); -- NWIC=1 --> null range for E_out
				                                             -- as long as Eri is not used in this case, we are ok
				irden, E: out std_logic);
end fsm_onetrans;

architecture behavior of fsm_onetrans is

type state is (S1,S2,S3,S4,S5,SW);
signal y: state;

signal CN: std_logic_vector (ceil_log2(N) - 1 downto 0);
signal sclr_CN, E_CN, cout_CN: std_logic;

   -- C: goes from 0 to NWIC - 1. When NWOC = NWIC
	-- C: goes from 0 to NWOC - 1. When NWOC = 2*NWIC
	-- ==> In general, C goes from 0 to NWOC-1
	signal C: std_logic_vector(ceil_log2(NWOC) -1 downto 0);
	signal sclr_C, E_C, cout_C: std_logic;
	signal irden_t: std_logic;
	signal Eri_aux: std_logic_vector (NWIC-1 downto 0);
	signal Eri_t, irden_vec: std_logic_vector (NWIC-2 downto 0);

signal resetn: std_logic;
	
begin

resetn <= not (rst);
-- Control of the Input Side:
-- *************************
-- Four different state machines for four different cases
-- The states machines are slighty different, but different enough
-- to have written them separatedly
-- NWIC = NWOC = 1
-- NWIC = NWOC > 1
-- NWOC = 2*NWIC, NWIC = 1
-- NWOC = 2*NWIC, NWIC > 1

f1: if NWIC = 1 and NWOC = 1 generate -- DCT 4x4, B=NO=8
		  -- FSM controller
		  Transitions: process (rst, clock)
		  begin
		      if rst = '1' then
					y <= S1;
				elsif (clock'event and clock = '1') then
					case y is
						when S1 =>
							if iempty = '1' then y <= S2; else y <= S1; end if;
						when S2 =>
							if iempty = '0' and ofull = '0' then
								if cout_CN = '1' then y <= SW; else y <= S2; end if;
							else
								y <= S2;
							end if;
						when SW =>
							if CN = conv_std_logic_vector(N-2,ceil_log2(N)) then y <= S2; else y <= SW; end if;
							
						when others =>
							y <= S1;
					end case;
				end if;
			end process;
			
			Outputs: process (y, iempty, ofull, cout_CN, CN)
			begin
				-- Initialization of signals
				irden <= '0'; E <= '0'; sclr_CN <= '0'; E_CN <= '0';
				case y is
					when S1 =>
					when S2 =>
						if iempty = '0' and ofull = '0' then
							irden <= '1'; E <= '1';
							if cout_CN = '1' then
								sclr_CN <= '1'; -- CN <= 0
							else
								E_CN <= '1'; -- CN <= CN + 1
							end if;
						end if;
					when SW =>
						if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
					when others =>
					
				end case;
			end process;
			
    end generate;

f2: if NWIC = 1 and NWOC = 2 generate -- DCT 4x4, B=8, NO=16
		  -- FSM controller
		  Transitions: process (rst, clock)
		  begin
		      if rst = '1' then
					y <= S1;
				elsif (clock'event and clock = '1') then
					case y is
						when S1 =>
							if iempty = '1' then y <= S2; else y <= S1; end if;
						when S2 =>
							if iempty = '0' and ofull = '0' then
								y <= S3;
							else
								y <= S2;
							end if;
						when S3 =>
						   -- CN = N-1? (we use cout_CN only when N is a power of 2)
							if cout_CN = '1' then y <= S4; else y <= S2; end if;
							
						when S4 =>
							if cout_CN = '1' then y <= SW; else y <= S4; end if;
						
						when SW =>
							if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then y <= S2; else y <= SW; end if;							
							
						when others =>
							y <= S1;
					end case;
				end if;
			end process;
			
			Outputs: process (y,iempty,ofull,cout_CN, CN)
			begin
				-- Initialization of signals
				irden <= '0'; E <= '0'; sclr_CN <= '0'; E_CN <= '0';
				case y is
					when S1 =>
						sclr_CN <= '1'; -- CN <= 0
					when S2 =>
						if iempty = '0' and ofull = '0' then
							irden <= '1'; E <= '1';
						end if;
					when S3 =>
						if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
					when S4 =>
						if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
					when SW =>
						if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;

					when others =>
					
				end case;
			end process;

    end generate;

f3: if NWIC > 1 and NWIC = NWOC generate -- DCT 8x8, 16x16  (and possibly 32x32, 64x64), B=NO=8
		  -- FSM controller
		  Transitions: process (rst, clock)
		  begin
		      if rst = '1' then
					y <= S1;
				elsif (clock'event and clock = '1') then
					case y is
						when S1 =>
							if iempty = '1' then y <= S2; else y <= S1; end if;
						when S2 =>
							if iempty = '0' and ofull = '0' then
								y <= S3;
							else
								y <= S2;
							end if;
						when S3 =>
							if iempty = '0' and ofull = '0' then
							   -- C = NWIC-1? . Checkin cout_C only works when NWIC is power of 2 (NWIC = NWOC)
								if cout_C = '1' then
									-- CN = N-1? (cout_CN is used only when N is a power of 2)
									if cout_CN = '1' then y <= S4; else y <= S2; end if;
								else
									y <= S3;
								end if;
							else
								y <= S3;
							end if;
						
						when S4 =>
							-- CN = N-1? (cout_CN is used only when N is a power of 2)
							if cout_CN = '1' then y <= SW; else y <= S4; end if;
							
						when SW =>
							if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then y <= S2; else y <= SW; end if;	
							
						when others =>
							y <= S1;							
					end case;
				end if;
			end process;
			
			Outputs: process (y,iempty,ofull, cout_C, cout_CN, CN)
			begin
				-- Initialization of signals
				irden_t <= '0'; E <= '0'; sclr_C <= '0'; E_C <= '0'; sclr_CN <= '0'; E_CN <= '0';
				case y is
					when S1 =>
						sclr_C <= '1'; -- C <= 0
					when S2 =>
						if iempty = '0' and ofull = '0' then
							irden_t <= '1';
							E_C <= '1'; -- C <= C + 1
						end if;
					when S3 =>
						if iempty = '0' and ofull = '0' then
							irden_t <= '1';
							if cout_C = '1' then -- C = NWIC-1? . Checkin cout_C only works when NWIC is power of 2 (NWIC = NWOC)
								sclr_C <= '1'; -- C <= 0
								E <= '1';
								if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
									sclr_CN <= '1'; -- CN <= 0;
								else
									E_CN <= '1'; -- CN <= CN + 1
								end if;
							else
								E_C <= '1'; -- C <= C + 1
							end if;
						end if;
					when S4 =>
						if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
							sclr_CN <= '1'; -- CN <= 0;
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
						
					when SW =>
						if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
						
					when others =>
								
				end case;
			end process;
			-- NWIC = 2: (8x8)
			-- C irden Eri NWIC-1-C     2^(NWIC-1-C)  
			-- 0   1    1     1             10
			-- 1   1    0     0             00
			-- NWIC = 4: (16x16)
			-- C irden Eri   NWIC-1-C   2^(NWIC-1-C)  
			-- 0    1  100      3           1000
			-- 1    1  010      2           0100
			-- 2    1  001      1           0010
			-- 3    1  000      0           0000
			-- 2^(NWIC-1-C) needs NWIC bits
			-- Eri needs NWIC-1 bits
			
			-- This formula works for 8x8, 16x16 (and also for 32x32, 64x64)
			-- If irden = '1':
			--     Eri = Drop the LSB of: 2^(NWIC-1-C)
			Eri_aux <= conv_std_logic_vector(2**(NWIC-1-conv_integer(C)),NWIC);
			Eri_t <= Eri_aux(NWIC-1 downto 1); -- NWIC-1 bits, dropping the LSB
			irden_vec <= (others => irden_t); -- NWIC-1 bits
			Eri <= Eri_t and irden_vec;

			irden <= irden_t;
			
			-- This only works (using cout_C) when NWIC is a power of 2
--			cC: lpm_counter generic map (LPM_WIDTH => ceil_log2(NWIC), LPM_DIRECTION => "UP")
--			    port map (clock => clock, cnt_en => E_C, sclr => sclr_C, aclr => rst, q => C, cout => cout_C);
			cC: my_counter generic map (COUNT => NWIC)
                port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_C, sclr => sclr_C, Q => C, z => cout_C);
			
    end generate;
	 
f4: if NWIC > 1 and NWOC = 2*NWIC generate -- DCT 8x8, 16x16  (and possibly 32x32, 64x64), B=8, NO=16
		  -- FSM controller
		  Transitions: process (rst, clock)
		  begin
		      if rst = '1' then
					y <= S1;
				elsif (clock'event and clock = '1') then
					case y is
						when S1 =>
							if iempty = '1' then y <= S2; else y <= S1; end if;
						when S2 =>
							if iempty = '0' and ofull = '0' then
								y <= S3;
							else
								y <= S2;
							end if;
						when S3 =>
							if iempty = '0' and ofull = '0' then
							   -- C = NWIC-1?. C goes from 0 to NWOC-1
								if C = conv_std_logic_vector(NWIC-1,ceil_log2(NWOC)) then y <= S4; else y <= S3; end if;
							else
								y <= S3;
							end if;
						when S4 =>
						   -- C = NWOC-1? . Checkin cout_C only works when NWOC is power of 2
							if cout_C = '1' then
							   -- CN = N-1? (cout_CN is used only when N is a power of 2)
								if cout_CN = '1' then y <= S5; else y <= S2; end if;
							else
								y <= S4;
							end if;
						
						when S5 =>
						   -- CN = N-1? (cout_CN is used only when N is a power of 2)
							if cout_CN = '1' then y <= SW; else y <= S5; end if;
							
						when SW =>
							if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then y <= S2; else y <= SW; end if;								
							
					end case;
				end if;
			end process;
			
			Outputs: process (y,iempty,ofull, C, cout_C, cout_CN,CN)
			begin
				-- Initialization of signals
				irden_t <= '0'; E <= '0'; sclr_C <= '0'; E_C <= '0'; sclr_CN <= '0'; E_CN <= '0';
				case y is
					when S1 =>
						sclr_C <= '1'; -- C <= 0
					when S2 =>
						if iempty = '0' and ofull = '0' then
							irden_t <= '1';
							E_C <= '1'; -- C <= C + 1
						end if;
					when S3 =>
						if iempty = '0' and ofull = '0' then
							irden_t <= '1';
							E_C <= '1'; -- C <= C + 1
							-- C = NWIC-1?. C goes from 0 to NWOC-1
							if C = conv_std_logic_vector(NWIC-1,ceil_log2(NWOC)) then
								E <= '1';
							--else
							--	E_C <= '1'; -- C <= C + 1
							end if;
						end if;					
					when S4 =>						
						if cout_C = '1' then -- C = NWOC-1? . Checkin cout_C only works when NWOC is power of 2
							sclr_C <= '1'; -- C <= 0
							if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
								sclr_CN <= '1'; -- CN <= 0
							else
								E_CN <= '1'; -- CN <= CN + 1
							end if;
						else
							E_C <= '1'; -- C <= C + 1;
						end if;
						
					when S5 =>
						if cout_CN = '1' then -- CN = N-1? (cout_CN is used only when N is a power of 2)
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;
						
					when SW =>
						if CN = conv_std_logic_vector (N-2, ceil_log2(N)) then
							sclr_CN <= '1'; -- CN <= 0
						else
							E_CN <= '1'; -- CN <= CN + 1
						end if;						
				end case;
			end process;
			-- NWIC = 2: (8x8)
			-- C irden Eri NWIC-1-C     2^(NWIC-1-C)  
			-- 0   1    1     1             10
			-- 1   1    0     0             00
			-- NWIC = 4: (16x16)
			-- C irden Eri   NWIC-1-C   2^(NWIC-1-C)  
			-- 0    1  100      3           1000
			-- 1    1  010      2           0100
			-- 2    1  001      1           0010
			-- 3    1  000      0           0000
			-- 2^(NWIC-1-C) needs NWIC bits
			-- Eri needs NWIC-1 bits
			-- In this case, C goes from 0 to NWOC-1 (NWOC = 2*NWIC)
			-- For the formula, we only need to take C from 0 to NWIC-1.
			-- This formula works for 8x8, 16x16 (and also for 32x32, 64x64)
			-- If irden = '1':
			--     Eri = Drop the LSB of: 2^(NWIC-1-C)
			Eri_aux <= conv_std_logic_vector(2**(NWIC-1-conv_integer(C(ceil_log2(NWIC)-1 downto 0))),NWIC);
			Eri_t <= Eri_aux(NWIC-1 downto 1); -- NWIC-1 bits, dropping the LSB
			irden_vec <= (others => irden_t); -- NWIC-1 bits
			Eri <= Eri_t and irden_vec;

			irden <= irden_t;
			-- This only works (using cout_C) when NWOC is a power of 2
--			cC: lpm_counter generic map (LPM_WIDTH => ceil_log2(NWOC), LPM_DIRECTION => "UP")
--			    port map (clock => clock, cnt_en => E_C, sclr => sclr_C, aclr => rst, q => C, cout => cout_C);
			cC: my_counter generic map (COUNT => NWOC)
                port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_C, sclr => sclr_C, Q => C, z => cout_C);
    end generate;

--cCN: lpm_counter generic map (LPM_WIDTH => ceil_log2(N), LPM_DIRECTION => "UP")
--	 port map (clock => clock, cnt_en => E_CN, sclr => sclr_CN, aclr => rst, q => CN, cout => cout_CN);

cCN: my_counter generic map (COUNT => N)
     port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_CN, sclr => sclr_CN, Q => CN, z => cout_CN);	 
end behavior;

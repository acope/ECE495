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

entity DCT_2d_onetrans is
-- IMPORTANT: we input 'N' columns, after that we have to wait 'N-1' cycles to place the next batch of
-- 'N' columns. This is because the transposing matrix needs N-1 cycles to transmit data to the other 1d dct
	generic (N: INTEGER:= 8;-- Size of the DCT
				NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
				B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
														
				-- Output bits for first 1D DCT: [NOa NOa-1]
				NO_a: INTEGER:= 16;
				-- Final output format, or output format of the second 1D DCT				
				NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
				NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).										
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
	port (	clock: in std_logic;	
			   resetn: in std_logic; -- initializes FSM and counters
				X : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
				E : in std_logic; -- enable for all the register chain
				Y : out std_logic_vector (N*NO - 1 downto 0); 
				v: out std_logic); -- output validity signal
end DCT_2d_onetrans;

architecture structure of DCT_2d_onetrans is

	component DCT_DA_cover
		generic (N: INTEGER:=8; -- Size of the DCT. 8,16 are supported --> only even-odd decomposition
										-- 2,3,4,5,6,7 are supported --> no even-odd decomposition
					NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
					B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of w[n] (if exists) is 'B+1'
					op: INTEGER:= 0;  -- Output truncation scheme:
											-- op = 0: saturation/truncation, op = 1: truncation, op = 2: Use max bit-width
					NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
					NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).
											--   0 <= NO <= L_FIR, 0 <= NQ <= NH+B-2
					USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive. N=2,3 (L=2,3) is not allowed here
														-- "NO" --> uses simple VHDL statement. All N's (all L's) are allowed here
		port (	clock: in std_logic;	
					X : in std_logic_vector (N*B -1 downto 0);
					E : in std_logic; -- enable for the input registers
					Z : out std_logic_vector (N*L_FIR_out(NH,B,N,NO,op) - 1 downto 0); 				
					rst: in std_logic;
					v: out std_logic);
	end component;
	
	component dffe
    port ( d : in  STD_LOGIC;
	        clrn: in std_logic:= '1';
			  prn: in std_logic:= '1';
           clk : in  STD_LOGIC;
			  ena: in std_logic;
           q : out  STD_LOGIC);
	end component;
	
	constant op: INTEGER:= 0;  -- Output truncation scheme: saturation/truncation
	
	constant NQ_a: INTEGER:= NO_a-1; -- this is to guarantee that [NO_a NQ_a] is between [-1,1)
	constant B_b: INTEGER:= NO_a; -- the output size of the first DCT is the input size of the second DCT
	constant M: integer:= N/2; -- M represents the # of multiplications within each dot product
		
	signal Z, ZT: std_logic_vector (N*NO_a - 1 downto 0);
	signal vi, E_M, Eo_d, Eo, s_M: std_logic;
	signal rst: std_logic;
	
	type state is (S1,S2);
	signal ys: state;
	signal E_C, cout_C, sclr_C: std_logic;
	signal C: std_logic_vector(ceil_log2(N)-1 downto 0);
	
begin
	
	Transitions: process (resetn, clock)
	begin
		if resetn <= '0' then
			ys <= S1;
		elsif (clock'event and clock = '1') then
			case ys is
				when S1 =>
					if vi = '1' then
						if cout_C = '1' then -- C = N-1?
							ys <= S2;
						else
							ys <= S1;
						end if;
					else
						ys <= S1;
					end if;
					
				when S2 =>
					if C = conv_std_logic_vector(N-2,ceil_log2(N)) then ys <= S1; else ys <= S2; end if;
						
			end case;
		end if;
	end process;

	Outputs: process (ys, C, vi, cout_C)
	begin
		-- Initialization of signals
		Eo_d <= '0'; E_C <= '0'; sclr_C <= '0'; E_M <= '0'; s_M <= '0';
		case ys is
			when S1 =>
				if vi = '1' then
					E_M <= '1';
					if cout_C = '1' then
						sclr_C <= '1'; -- C <= 0
						Eo_d <= '1';
					else
						E_C <= '1'; -- C <= C + 1
					end if;
				end if;
				
			when S2 =>
				s_M <= '1'; Eo_d <= '1'; E_M <= '1';
				if C = conv_std_logic_vector(N-2,ceil_log2(N)) then
					sclr_C <= '1'; -- C <= 0
				else
					E_C <= '1'; -- C <= C + 1
				end if;
				
		end case;
	end process;

rst <= not(resetn);
df: dffe port map (d => Eo_d, clrn => '1', prn => '1', clk => clock, ena => '1', q => Eo);
			
--cC: lpm_counter generic map (LPM_WIDTH => ceil_log2(N), LPM_DIRECTION => "UP")
--	 port map (clock => clock, cnt_en => E_C, aclr => rst, sclr => sclr_C, q => C, cout => cout_C);
cC: my_counter generic map (COUNT => N)
    port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_C, sclr => sclr_C, Q => C, z => cout_C);
     	 
ga: DCT_DA_cover generic map (N, NH, B, op, NO_a, NQ_a, USE_PRIM)
    port map (clock => clock, X => X, E => E, Z => Z, rst => rst, v => vi);

mm: transp_array generic map (N => N, B => NO_a)
    port map (clock => clock, Xi => Z , E => E_M, s => s_M, Zo => ZT);
	 
gb: DCT_DA_cover generic map (N, NH, B_b, op, NO, NQ, USE_PRIM)
    port map (clock=>clock, X => ZT, E => Eo, Z => Y, rst => rst, v => v);

end structure;
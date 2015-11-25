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

-- Supported cases: N=8,16, 32, 64 (even-odd decomposition)
--                  N=4 (no even-odd decomposition)
--                  NH=10,12,14,16
--                  NO = 8, 16, and possibly 10,12,14 (we have to tweak the code to do this)
--                  In the second DCT: B = NO (we fix this, investigate how we can relax this)
--                    Also, B (2nd DCT) = NO (first DCT)
-- These parameters do not violate the equation: 0 <= NQ <= NH+B-2 for both 1D DCTs

-- For all cases except NWIC=NWOC (4x4, B=NO=8)
--   After N columns, ALWAYS wait 'N' cycles. This is because the output buffer
--   In the case of 'onetrans', add 'N-1' cycles
entity dct_ip is
	generic (PLBW: INTEGER:= 32; -- only one supported so far,
                      --	if PLBW=64, the interface will need modifications (especially for case 4x4)
				N: INTEGER:= 8;  -- DCT size (4,8,16)
				NH: INTEGER:= 16;
				B: INTEGER:= 8;
				NO: INTEGER:= 8;	
				NQ: INTEGER:=15;
				USE_PRIM: STRING:= "YES";
				IMPLEMENTATION: STRING:= "onetrans");
	port (	clock: in std_logic;
				rst: in std_logic; -- high-level reset				
				DI: in std_logic_vector (31 downto 0);
				DO: out std_logic_vector (31 downto 0);
				ofull, iempty: in std_logic;
				owren, irden: out std_logic);				
end dct_ip;

architecture structure of dct_ip is

       component CORDIC_FP_top 
            port ( clock, reset, s, mode: in std_logic;
                   Xin, Yin, Zin: in std_logic_vector (15 downto 0);
                   done: out std_logic;
                   Xout, Yout, Zout: out std_logic_vector (15 downto 0)
                   );
        end component;

--	component DCT_2d
--		generic (N: INTEGER:= 8;-- Size of the DCT
--					NH: INTEGER:= 16; -- Bit-width of the coefficients (h[n])
--					B: INTEGER:= 8;  -- Bit-width of x[n] ==> number of bits of s[n] (if exists) is 'B+1'
															
--					-- Output bits for first 1D DCT: [NOa NOa-1]
--					NO_a: INTEGER:= 16;
--					-- Final output format, or output format of the second 1D DCT				
--					NO: INTEGER:= 16; -- Here we define the format: [NO NQ]				                  
--					NQ: INTEGER:= 15; -- [NO NQ] define the output format (op != 2).										
--					USE_PRIM: STRING:= "YES"; -- "YES" --> use the ROM(2**L)x1 primitive,
--														-- "NO" --> uses simple VHDL statement.); -- text file storing the LUT values
--					IMPLEMENTATION: STRING:= "onetrans"); -- "onetrans", "fullypip".
--		port (	clock: in std_logic;	
--					rst: in std_logic; -- High-level reset, initializes FSM, counters, and 'v' shift register
--					X : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
--					E : in std_logic; -- enable for all the register chain
--					Y : out std_logic_vector (N*NO - 1 downto 0); 
--					v: out std_logic); -- output validity signal
--	end component;
	

--	component fsm_fullypip
--		generic (NWIC: INTEGER:= 1;
--					NWOC: INTEGER:= 1;
--					N: INTEGER:= 8 );
--		port (	clock: in std_logic;
--					rst: in std_logic; -- high-level reset
--					iempty, ofull: in std_logic;
--					Eri: out std_logic_vector (NWIC-2 downto 0); -- NWIC=1 --> null range for E_out
--																				-- as long as Eri is not used in this case, we are ok
--					irden, E: out std_logic);
--	end component;
	
	component fsm_onetrans
		generic (NWIC: INTEGER:= 1;
					NWOC: INTEGER:= 1;
					N: INTEGER:= 8);
		port (	clock: in std_logic;
					rst: in std_logic; -- high-level reset
					iempty, ofull: in std_logic;
					Eri: out std_logic_vector (NWIC-2 downto 0); -- NWIC=1 --> null range for E_out
																				-- as long as Eri is not used in this case, we are ok
					irden, E: out std_logic);
	end component;
	
	signal resetn: std_logic;
	
	type state is (S1,S2,S3);
	signal ys: state;
	
	-- Assumption:
	-- * All the constant assume that the size of the bus is 32 bits
	-- NWIC, NWOC are always powers of 2
	
	-- Assume that we can handle NO = 14, 12, 10 as it they were 16 bits (we only use the LSBs)
	constant NWIC: INTEGER:= N/(PLBW/B); -- number of 32-bit words needed for an input column
	constant NWOC: INTEGER:= NWIC*ceil_a(NO,B);  -- number of 32-bit words needed for an output column
	
	constant NO_a: INTEGER:= NO; -- we fix this. TODO: investigate, whether we can relax this
	-- For PLBW = 32, B = 8:
	-- ********************
	-- NWIC: # of 32-bit words needed for an input column:
	--  4x4 --> NWIC = 1    8x8 --> NWIC = 2    16x16 --> NWIC = 4
	--  In general: NWIC = N/4
	
	-- NWOC: # of 32-bit words needed for an output column (or output row, assuming the input block is square)
   -- NO = 8: 4x4  --> NWOC = 1   8x8 --> NWOC = 2    16x16 --> NWOC = 4
	-- NO = 16: 4x4 --> NWOC = 2   8x8 --> NWOC = 4    16x16 --> NWOC = 8
	-- In general: NWOC = NWIC*(ceil(NO/8)); 
	--    NO = 8 --> Same size for both input and output pixels --> NWOC = NWIC
	--    NO = 16, 14, 12, 10 --> Output pixels takes twice the size as input pixels --> NWOC = 2*NWIC
	-- * Important: For this to work for NO=14,12,10, we need to modify the way
	--              X and Y are created. Recall: NO=14,12, 10 are like NO=16, but we only consider
	--              the LSB bits.
	
	signal Eri: std_logic_vector (NWIC-2 downto 0);
	-- if NWIC=1 --> range is null, as long as Eri is not used, we are ok
	
	signal CO: std_logic_vector (ceil_log2(NWOC)-1 downto 0);	
   signal E_CO, sclr_CO, cout_CO: std_logic;
	
	signal C: std_logic_vector (ceil_log2(N)-1 downto 0);
   signal E_C, sclr_C, cout_C: std_logic;
	
	type chunk is array(NWOC-1 downto 0) of std_logic_vector (PLBW-1 downto 0); -- if NWOC = 1 --> null range
	signal group_out: chunk;
	
	type chunk_mat is array (N downto 0) of std_logic_vector(N*NO - 1 downto 0);
	signal Ymat: chunk_mat;
	
	-- Signal that grabs the output row:
	-- If B=NO=8 --> the size N*B (B*ceil_a(NO,B) = 8*1)
	-- If B=8, NO=16 --> the size is N*16 (B*ceil_a(NO,B) = 8*2)
	-- If B=8, NO=10,12,14 --> the size is N*16 (B*ceil_a(NO,B) = 8*2)
	signal YO: std_logic_vector (N*B*ceil_a(NO,B) -1 downto 0);
	
	signal E, v, E_buf: std_logic;
	signal X : std_logic_vector (N*B -1 downto 0);
   signal Y, Y_dct2d : std_logic_vector (N*NO - 1 downto 0); 

begin

a0: assert (N = 4 or N = 8 or N = 16)
    report "Only N = 4, 8, 16 are allowed in this interface. N=32,64 might be allowed later!"
    severity error;
	 
a1: assert (NO = 8 or NO = 10 or NO = 12 or NO = 14 or NO=16)
    report "Only NO = 8,10,12,14,16 are allowed in this interface!"
    severity error;

a2: assert (B = 8)
    report "Only B = 8 is allowed in this interface!"
    severity error;

a3: assert (NH = 10 or NH = 12 or NH = 14 or NH=16)
    report "Only NH = 10,12,14,16 are allowed in this interface!"
    severity error;

a4: assert (PLBW = 32)
    report "Only PLBW = 32 is allowed in this interface!"
    severity error;
	 
--sa: if IMPLEMENTATION = "fullypip" generate		
--		 fa: fsm_fullypip generic map (NWIC,NWOC,N)
--		     port map (clock, rst, iempty, ofull, Eri, irden,E);
--    end generate;
	 
sb: if IMPLEMENTATION = "onetrans" generate		
		 fb: fsm_onetrans generic map (NWIC,NWOC,N)
		     port map (clock, rst, iempty, ofull, Eri, irden,E);
    end generate;

gi: if NWIC = 1 generate -- 4x4
        X <= DI;
    end generate;

resetn <= not (rst);
-- Processing occurs column-wise: Each column has N pixels: [1st pixel 2nd pixel... Nth pixel]'
-- Order: Each 32-bit input word carries 4 pixels. The first pixel is located in the MSB part, the last pixel in the LSB part
-- X: input column: The first 32-bit word goes to the MSB part, and the last 32-bit word goes to the LSB part	 
gh: if NWIC /= 1 generate -- 8x8, 16x16, 32x32, 64x64
		  ry: for i in NWIC-1 downto 1 generate
--		          ryi: lpm_ff generic map (LPM_WIDTH => PLBW)
--					      port map (data => DI, clock => clock, q => X(PLBW*(i+1) -1 downto PLBW*i), enable => Eri(i-1),
--							          aclr => rst, aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0');
				  ryi: my_rege generic map (N => PLBW)
                       port map (clock => clock, resetn => resetn, E => Eri(i-1), sclr => '0', D => DI, Q => X(PLBW*(i+1) -1 downto PLBW*i));
  
			   end generate;
		  X(PLBW -1 downto 0) <= DI;
    end generate;

-- Output Multiplexer:
oi: if NWOC = 1 generate -- 4x4, B=8, NO=8
        DO <= Ymat(N);
    end generate;
	 
og: if NWOC /= 1 generate
		  fp: if NO = 8 or NO = 16 generate
		         -- With N being 4,8,16, N*NO is multiple of PLBW=32
					YO <= Ymat(N);
		  end generate;
		  fq: if NO /= 8 and NO/= 16 generate -- NO=10,12,14
		         -- With N being 4,8,16, N*16 is multiple of PLBW=32
					mz: for i in N-1 downto 0 generate
					       -- Defining: YO(16*(i+1) -1 downto 16*i)
					       YO(NO + 16*i -1 downto 16*i) <= Ymat(N)(NO*(i+1) -1 downto NO*i);
							 YO(16*(i+1) - 1 downto NO+16*i) <= (others => '0');
					    end generate;
		  end generate;
		  
		  mo: for i in NWOC-1 downto 0 generate
					 group_out(i) <= YO(PLBW*(i+1) -1 downto PLBW*i);
			   end generate;						 

	     DO <= group_out(conv_integer(NWOC-1-CO));
	 end generate;

-- Controlling the Output side:
n1: if NWOC = 1 generate
			owren <= v;
			Ymat(N) <= Y_dct2d;
    end generate;
	 
n2: if NWOC > 1 generate
		-- FSM controller
		Transitions: process (rst, clock)
		begin
			if rst = '1' then
				ys <= S1;
			elsif (clock'event and clock = '1') then
				case ys is
					when S1 =>
						if v = '1' then ys <= S1; else ys <= S2; end if;
					when S2 =>
						if v = '1' then
							if cout_C = '1' then -- C = N-1? (checking cout_C only works when N is a power of 2)
								ys <= S3;
							else
								ys <= S2;
							end if;
						else
							ys <= S2;
						end if;
					when S3 =>
					   -- CO = NWOC-1? . Checking cout_CO only works when NWOC is power of 2
						if cout_CO = '1' then
							if cout_C = '1' then ys <= S2; else ys <= S3; end if;
						else
							ys <= S3;
						end if;
							
				end case;
			end if;
		end process;
				
		Outputs: process (ys, cout_C, cout_CO, v)
		begin
			-- Initialization of signals
			sclr_CO <= '0'; E_CO <= '0'; owren <= '0';
			sclr_C <= '0'; E_C <= '0'; E_buf <= '0';
			case ys is
				when S1 =>
					sclr_CO <= '1'; -- CO <= 0
					sclr_C <= '1'; -- C <= 0
				when S2 =>
					if v = '1' then
						E_buf <= '1';
						if cout_C = '1' then -- C = N-1?
							sclr_C <= '1'; -- C <= 0
						else
							E_C <= '1'; -- C <= C + 1
						end if;				
					end if;
				when S3 =>
					owren <= '1';
					-- CO = NWOC-1? . Checking cout_CO only works when NWOC is power of 2
					if cout_CO = '1' then
						sclr_CO <= '1'; -- CO <= 0
						E_buf <= '1';
						if cout_C = '1' then -- C = N - 1?
							sclr_C <= '1'; -- C <= 0
						else
							E_C <= '1'; -- C <= C + 1
						end if;							
					else
						E_CO <= '1'; -- CO <= CO + 1
					end if;
				end case;
			
		end process;

--		cCO: lpm_counter generic map (LPM_WIDTH => ceil_log2(NWOC), LPM_DIRECTION => "UP")
--		     port map (clock => clock, cnt_en => E_CO, sclr => sclr_CO, aclr => rst, q => CO, cout => cout_CO);   
        cCO: my_counter generic map (COUNT => NWOC)
             port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_CO, sclr => sclr_CO, Q => CO, z => cout_CO);
                 		     
		--cC: lpm_counter generic map (LPM_WIDTH => ceil_log2(N), LPM_DIRECTION => "UP")
		--    port map (clock => clock, cnt_en => E_C, sclr => sclr_C, aclr => rst, q => C, cout => cout_C);
        cC: my_counter generic map (COUNT => N)
            port map (clock => clock, resetn => resetn, clk_en => '1', cnt_en => E_C, sclr => sclr_C, Q => C, z => cout_C);
        
		Ymat(0) <= Y_dct2d;
		buffo: for i in 0 to N-1 generate
--                    byo: lpm_ff generic map (LPM_WIDTH => N*NO)
--                         port map (data => Ymat(i), clock => clock, q => Ymat(i+1), enable => E_buf,
--                                   aclr => rst, aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0');
				    byo: my_rege generic map (N => N*NO)
                         port map (clock => clock, resetn => resetn, E => E_buf, sclr => '0', D => Ymat(i), Q => Ymat(i+1) );
		 end generate;
		 
	end generate;		
-- Note that this VHDL IP assumes that the # of output bits of the first DCT match
-- the # of input bits of the second DCT
-- Here, we fix NO_a = NO
--gIP: DCT_2d generic map (N, NH, B, NO_a, NO, NQ, USE_PRIM, IMPLEMENTATION)
--	  port map (clock => clock, rst => rst, X => X, E => E, Y => Y_dct2d, v => v);
	  
--	   CORDIC: CORDIC_FP_top 
--          port map( clock => clock, reset => rst, s => E, mode => mode, Xin => Xin, Yin => Yin, Zin => Zin, done => v, Xout => Xout, Yout => Yout, Zout => Zout);

end structure;

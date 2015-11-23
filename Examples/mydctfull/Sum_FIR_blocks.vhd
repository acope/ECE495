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

entity sum_FIR_blocks is
	generic (file_LUT: STRING:= "LUT_values[1].txt";
				USE_PRIM: STRING:= "YES";
				NY : INTEGER;
				NH: INTEGER:= 16;
				B: INTEGER:= 8;
				size_I: INTEGER:= 9;
				L_FIR: INTEGER:=33;
				M  : INTEGER:= 4;
				L  : INTEGER:= 4;
				NO : INTEGER:= 16;
				NQ : INTEGER:= 15;
				op: INTEGER:= 0);  -- Output truncation scheme
	port ( UF_2d : in std_logic_2d;
			 clock: in std_logic;			 
			 Y  : out std_logic_vector (NY - 1 downto 0));
end sum_FIR_blocks;

architecture structure of sum_FIR_blocks is

	constant L_fbk: INTEGER:=  NH + size_I + ceil_log2(L+1) - 1;  -- Max # of bits of each Filter Block
	-- L additions of the multiplications of W (size_I bits) with the coefficients (NH bits)

	constant LV: INTEGER:= ceil_log2(M/L); -- number of levels of the array of adders that adds each FIR block output
	constant XL: int_vector(LV downto 0):= Get_X(LV,M/L);
	
	type chunk_UF is array(M/L - 1 downto 0) of std_logic_vector(L*size_I -1 downto 0);
	signal UF: chunk_UF;
	
	type chunk_aux is array (3 downto 0) of std_logic_vector (NO - 1 downto 0);
	signal Y_aux: chunk_aux;
	
	type chunk_3D is array (natural range <>, natural range <>) of std_logic_vector(L_fbk + LV - 1 downto 0); 
	signal yf: chunk_3D(LV downto 0, M/L - 1 downto 0);
	signal yf_q: chunk_3D(LV - 1 downto 0, M/L - 1 downto 0);
	
	signal all_1_or_0 : std_logic;
	signal auxi: std_logic_vector (L_FIR - (NO+NH+B-2-NQ) downto 0);
	signal Yd: std_logic_vector (NY - 1 downto 0);
	
begin

-- getting UF from UF_2d. UF_2d is a matrix, and UF is a collection of vector stack up.
st: for i in 0 to M/L - 1 generate -- M must be multiple of L
		ga: for j in 0 to size_I*L - 1  generate
					UF(i)(j) <= UF_2d(i,j);
			 end generate;
	 end generate;

-- Generation of the Filter Blocks:
-- 'size_I' inputs of 'L' bits
gf: for i in 0 to M/L -1 generate
		 gFIR: FIR_block generic map (M => M, size_I => size_I, NH => NH, L => L, P => i + 1 ,
												L_fbk => L_fbk, file_LUT => file_LUT, USE_PRIM => USE_PRIM)
				 port map (clock => clock, U => UF(i), y => yf(0,i)(L_fbk - 1 downto 0));
	 end generate;
	 
-- Now we need to add all the outputs yf(0,i).
gi: for i in 1 to LV generate -- If M/L = 1 --> LV = 0 and this loop is not run
		-- The registers are created:
		gk: for k in 0 to XL(i-1)-1 generate
--					rk: lpm_ff generic map (LPM_WIDTH => L_fbk + (i-1))
--						 port map ( data => yf(i-1,k)(L_fbk + (i-1) - 1 downto 0), clock => clock,
--										enable => '1', aclr => '0', aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0',
--										q => yf_q(i-1,k)(L_fbk + (i-1) - 1 downto 0));										
                    rk: my_rege generic map (N => L_fbk + (i-1))
                        port map (clock => clock, resetn => '1', E => '1', sclr => '0', D => yf(i-1,k)(L_fbk + (i-1) - 1 downto 0),
                                                                                        Q => yf_q(i-1,k)(L_fbk + (i-1) - 1 downto 0));

					yf_q(i-1,k)(L_fbk + i-1) <= yf_q(i-1,k)(L_fbk + (i-1) - 1); -- sign extension, this would be 'yf_p'
			 end generate;

		-- Adders are created:
		gj: for j in 0 to XL(i)-2 generate
--					gjs: lpm_add_sub generic map (LPM_WIDTH => L_fbk + i, LPM_DIRECTION => "ADD")
--						  port map (dataa => yf_q(i-1,2*j)(L_fbk + i - 1 downto 0),
--										datab => yf_q(i-1,2*j + 1)(L_fbk + i - 1 downto 0),
--										result => yf(i,j)(L_fbk + i - 1 downto 0));
										
					gjs: my_addsub generic map (N => L_fbk + i)
					     port map (addsub => '0', x => yf_q(i-1,2*j)(L_fbk + i - 1 downto 0), y => yf_q(i-1,2*j + 1)(L_fbk + i - 1 downto 0), s => yf(i,j)(L_fbk + i - 1 downto 0));
			 end generate;

		gjp: for j in XL(i)-1 to XL(i)-1 generate
					gjps: if (XL(i-1) rem 2 = 0) generate -- X(i-1) is even?, is the same as asking 2*X(i) = X(i-1)
--								g6: lpm_add_sub generic map (LPM_WIDTH => L_fbk + i, LPM_DIRECTION => "ADD")
--									  port map (dataa => yf_q(i-1, 2*j)(L_fbk + i - 1 downto 0),
--											 datab => yf_q(i-1, 2*j + 1)(L_fbk + i - 1 downto 0), 
--											 result => yf(i,j)(L_fbk + i - 1 downto 0));
            					g6: my_addsub generic map (N => L_fbk + i)
                                    port map (addsub => '0', x => yf_q(i-1, 2*j)(L_fbk + i - 1 downto 0),
                                                             y => yf_q(i-1, 2*j + 1)(L_fbk + i - 1 downto 0),
                                                             s => yf(i,j)(L_fbk + i - 1 downto 0));
							 end generate;
					 
					gjpns: if (XL(i-1) rem 2 = 1) generate -- X(i-1) is odd?, is the same as asking 2*X(i) /=X(i-1)
									yf(i,j)(L_fbk + i - 1 downto 0) <= yf_q(i-1,2*j)(L_fbk + i - 1 downto 0);
							 end generate;
			  end generate;
					 
	 end generate;

	 oi: if op = 0 generate -- saturation/truncation
				-- YFb(LV,0): final adder tree output (not yet chopped, not even to L_FIR bits)
				auxi <= yf(LV,0)(L_FIR-1 downto (NO+NH+B-2-NQ) - 1);
				all_1_or_0 <= and_or_reducer(auxi);
									
				--process (all_1_or_0,yf(LV,0)(L_FIR-1))
				process (all_1_or_0,yf(LV,0))
				begin
					if all_1_or_0 = '1' then
						Yd <= yf(LV,0)(NO+NH+B-2-NQ - 1 downto NH+B-2 - NQ); -- simple truncation of MSB and LSB (adder tree output)
					elsif yf(LV,0)(L_FIR-1) = '1' then
						Yd(NO-1) <= '1'; Yd(NO-2 downto 0) <= (others =>'0'); -- most negative value
					elsif yf(LV,0)(L_FIR-1) = '0' then
						Yd(NO-1) <= '0'; Yd(NO-2 downto 0) <= (others => '1'); -- most positive value
					else
						Yd <= (others => '0');		
					end if;				
				end process;
					
			end generate;
				
		oj: if op = 1 generate -- plain truncation
					Yd <= yf(LV,0)(NO+NH+B-2-NQ - 1 downto NH+B-2 - NQ);
			 end generate;
		  
		ok: if op = 2 generate
					Yd <= yf(LV,0)(L_FIR -1 downto 0); -- Y has size L_FIR
			 end generate;
							
--		ro: lpm_ff generic map (LPM_WIDTH => NY)
--			 port map (data => Yd, clock => clock, q => Y);
	    ro: my_rege generic map (N => NY)
            port map (clock => clock, resetn => '1', E => '1', sclr => '0', D => Yd, Q => Y);

end structure;

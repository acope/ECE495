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

entity FIR_block is
	generic (M:  INTEGER:= 32; -- number of nonrepetitive 'taps' = ceil (N/2), where N: # of taps
				size_I: INTEGER:= 9; -- size_I = B (nonsymmetry), size_I = B+1 (symmetry)
				NH: INTEGER:= 12; -- number of bits of each of the h[n] values
				L: INTEGER:= 4; -- # of bits of Sb, i.e. we have a L-input LUT
				P:  INTEGER:= 8; -- P: 1 --> M/L
										-- P can be better understood as the number of filter block we are working on
										-- e.g.: P = 1 ==> we are working with the first filter block of L coefficients
										-- Recall that each filter block has a different set of s[n] values, thus the LUT 
										-- values depend on each filter block are uniquely determined by P.				
				L_fbk: INTEGER:= 33; -- Max output bits for filter block. L_fbk = NH + size_I + ceil_log2(L+1) - 1
				file_LUT: STRING:= "LUT_values.txt";
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.);
	port (	clock: in std_logic;
				U : in std_logic_vector; -- length is either 'NL*(B+1)' or 'NL*B' depending on symmetry
				y : out std_logic_vector (L_fbk - 1 downto 0));
				
end FIR_block;

architecture structure of FIR_block is

	constant LO: INTEGER:= NH + ceil_log2(L); -- output bits of the underlying LUTs (L-to-LO LUT)
	constant LV_fbk: INTEGER:= ceil_log2(size_I);
				
	type chunk is array (size_I-1 downto 0) of std_logic_vector(L-1 downto 0);
	signal So: chunk;
	
	type chunk_3D is array (natural range <>, natural range <>) of std_logic_vector(L_fbk - 1 downto 0); 
   signal fb: chunk_3D(LV_fbk downto 0, size_I-1 downto 0); -- it should be more than LO since at each level the number of bits increases
	signal fb_q, fb_p: chunk_3D(LV_fbk - 1  downto 0, size_I-1 downto 0);
	
	constant X: int_vector(LV_fbk downto 0) := Get_X(LV_fbk,size_I);
	
begin
	
-- We create an array from the input 'S'
gS: for k in 0 to size_I-1 generate
			So(k) <= U((k+1)*L-1 downto k*L);
	 end generate;
	
-- Generating the LUTs to which S(0) to S((size_I-1)-1) are connected
  gL: for j in 0 to (size_I-1)-1 generate
		GLj: LUTn generic map (NH => NH, L => L, BT => 0, P => P, file_LUT => file_LUT, USE_PRIM => USE_PRIM)
			  port map (ub => So(j), fb => fb(0,j)(length_fb(0,LO,L_fbk)-1 downto 0));
    end generate;
	
	-- Generating the LUT to which S(size_I-1) is connected
	gLB: LUTn generic map (NH => NH, L => L, BT => 1, P => P, file_LUT => file_LUT, USE_PRIM => USE_PRIM)
		  port map (ub => So(size_I-1), fb => fb(0,size_I-1)(length_fb(0,LO,L_fbk)-1 downto 0));

-- Now, we create the adders and shifters for every level. Number of levels = LV_fbk = ceil_log2(sizeI):
gi: for i in 1 to LV_fbk generate
		
		gk: for k in 0 to X(i-1)-1 generate
				 gk_ev: if (k rem 2 = 0) generate -- Even indices don't have the shifting
--								rk_ev: lpm_ff generic map (LPM_WIDTH => length_fb(i-1,LO,L_fbk))
--									  port map (	data => fb(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0), clock => clock, enable => '1',
--														aclr => '0', aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0',
--														q => fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0));
					           rk_ev: my_rege generic map (N => length_fb(i-1,LO,L_fbk))
                                      port map (clock => clock, resetn => '1', E => '1', sclr => '0', D => fb(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0),
                                                                                                      Q => fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0));
                                                            
					-- Now we create the fb_p(i-1,k), which must have the same format as fb(i,k):
					-- When k is even, we need to extend the sign '1+2^(i-1)' times to the leftmost part
					-- length of fb_p(i-1,k): length_fb(i,LO,L_fbk)
							   gext: for u in length_fb(i,LO,L_fbk)-1 downto length_fb(i-1,LO,L_fbk) generate
											fb_p(i-1,k)(u) <= fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1); -- extending the sign 
										end generate;
							fb_p(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0) <= fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0);
				 end generate;
				 
				 gk_od: if (k rem 2 = 1) generate -- Odd indices have the shifting
--								rk_odd: lpm_ff generic map (LPM_WIDTH => length_fb(i-1,LO,L_fbk))
--										  port map (data => fb(i-1,k)(length_fb(i-1,LO,L_fbk) - 1 downto 0), clock => clock, enable => '1',
--														aclr => '0', aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0',
--													   q => fb_q(i-1,k)(length_fb(i-1,LO,L_fbk) - 1 downto 0));
					            rk_odd: my_rege generic map (N => length_fb(i-1,LO,L_fbk))
                                        port map (clock => clock, resetn => '1', E => '1', sclr => '0', D => fb(i-1,k)(length_fb(i-1,LO,L_fbk) - 1 downto 0),
                                                                                                        Q => fb_q(i-1,k)(length_fb(i-1,LO,L_fbk) - 1 downto 0));				 
								-- Now we create the fb_p(i-1,k), which must have the same format as fb(i,j):
								-- When k is odd, we need to extend the MSB sign one bit.
								-- Also, we need to right shift by 2^(i-1) bits , i.e. add 2^(i-1) zeros to the right
								
								fb_p(i-1,k)(2**(i-1) -1 downto 0) <= (others => '0');
								
								goo: if ((NH + ceil_log2(L) + i-1 + 2**(i-1) - 1) < L_fbk) generate
											gee: if NH + ceil_log2(L) + i + 2**i - 1 <= L_fbk generate
														fb_p(i-1,k)(length_fb(i,LO,L_fbk)- 1) <= fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1); -- extending the sign 1 bit		 
														fb_p(i-1,k)(length_fb(i,LO,L_fbk)- 2 downto 2**(i-1)) <= fb_q(i-1,k)(length_fb(i-1,LO,L_fbk)-1 downto 0);
												  end generate;
											gii: if NH + ceil_log2(L) + i + 2**i - 1 > L_fbk generate
														fb_p(i-1,k)(length_fb(i,LO,L_fbk)- 1 downto 2**(i-1)) <= fb_q(i-1,k)(L_fbk - 2**(i-1) -1 downto 0);
												  end generate;
								end generate;

								gaa: if ((NH + ceil_log2(L) + i-1 + 2**(i-1) - 1) >= L_fbk) generate
											fb_p(i-1,k)(length_fb(i,LO,L_fbk)- 1 downto 2**(i-1)) <= fb_q(i-1,k)(L_fbk -2**(i-1) -1 downto 0);
								end generate;
								
				 end generate;
				 
			 end generate;
			 			 
			gj: for j in 0 to X(i)-2 generate
--						gjs: lpm_add_sub generic map (LPM_WIDTH => length_fb(i,LO,L_fbk), LPM_DIRECTION => "ADD")
--							  port map (dataa => fb_p(i-1,2*j)(length_fb(i,LO,L_fbk)-1 downto 0),
--											datab => fb_p(i-1,2*j+1)(length_fb(i,LO,L_fbk)-1 downto 0),
--											result => fb(i,j)(length_fb(i,LO,L_fbk)-1 downto 0));
						gjs: my_addsub generic map (N => length_fb(i,LO,L_fbk))
                             port map (addsub => '0', x => fb_p(i-1,2*j)(length_fb(i,LO,L_fbk)-1 downto 0),
                                       y => fb_p(i-1,2*j+1)(length_fb(i,LO,L_fbk)-1 downto 0),
                                       s => fb(i,j)(length_fb(i,LO,L_fbk)-1 downto 0));
				 end generate;

			gjp: for j in X(i)-1 to X(i)-1 generate
						gjps: if (X(i-1) rem 2 = 0) generate -- X(i-1) is even?, is the same as asking 2*X(i) = X(i-1)
--									g6: lpm_add_sub generic map (LPM_WIDTH => length_fb(i,LO,L_fbk), LPM_DIRECTION => "ADD")
--									    port map (dataa => fb_p(i-1,2*j)(length_fb(i,LO,L_fbk)-1 downto 0),
--										          datab => fb_p(i-1,2*j+1)(length_fb(i,LO,L_fbk)-1 downto 0), 
--										          result => fb(i,j)(length_fb(i,LO,L_fbk)-1 downto 0));  
										 
									g6: my_addsub generic map (N => length_fb(i,LO,L_fbk))
                                        port map (addsub => '0', x => fb_p(i-1,2*j)(length_fb(i,LO,L_fbk)-1 downto 0),
                                                                 y => fb_p(i-1,2*j+1)(length_fb(i,LO,L_fbk)-1 downto 0), 
                                                                 s => fb(i,j)(length_fb(i,LO,L_fbk)-1 downto 0));
							end generate;
			 
						gjpns: if (X(i-1) rem 2 = 1) generate -- X(i-1) is odd?, is the same as asking 2*X(i) /=X(i-1)
									fb(i,j)(length_fb(i,LO,L_fbk)-1 downto 0) <= fb_p(i-1,2*j)(length_fb(i,LO,L_fbk)-1 downto 0);
								 end generate;
				end generate;
			 
	  end generate;

-- Output fb(LV_fbk,0)
   --y <= fb(LV_fbk,0)(L_fbk - 1 downto 0);
	y <= fb(LV_fbk,0);

end structure;
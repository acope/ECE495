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

library work;
use work.pack_xtras.all;

entity transp_array is
	generic (N: INTEGER:= 8;  -- Size of the matrix
				B: INTEGER:= 8); -- I/O bit-width
				
	port (	clock: in std_logic;
				Xi : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
				E : in std_logic; -- enable for all the register chain
				s: in std_logic;
				Zo : out std_logic_vector (N*B - 1 downto 0));						
end transp_array;

architecture structure of transp_array is

	type chunk is array (N-1 downto 0) of std_logic_vector(B-1 downto 0);
	signal X, Z: chunk;
		
	type chunk_2d is array (natural range <>, natural range <>) of std_logic_vector(B-1 downto 0);
	signal AM, BM: chunk_2d (N-2 downto 0, N-1 downto 0);
	signal RI, RO: chunk_2d (N-1 downto 0, N-1 downto 0);	
	
begin
-- Input X is considered as an vector
-- X: N groups of 'B' bits, one after the other (ordered from MSB to LSB). From X(0) to X(N-1)
-- Example: X(N*B -1 downto (N-1)*B) corrresponds to X(0)

gi: for i in 0 to N-1 generate
			X(i) <= Xi( (N-i)*B - 1 downto (N-(i+1))*B );
			Zo( (N-i)*B - 1 downto (N-(i+1))*B ) <= Z(i);	   
	 end generate;

-- X(0) to X(N-1) are input column-wise

-- Creation of the array of registers, and the array of muxes:
-- When all data is entered, RO will hold the matrix (that was input column-wise) with the columns in 
-- reverse order (because the first received column is shifted until it is placed in the last column of RO)
gm: for j in 0 to N-1 generate -- columns
		gn: for i in 0 to N-1 generate -- rows
--				gr: lpm_ff generic map (LPM_WIDTH => B)
--					 port map (data => RI(i,j), clock => clock, q => RO(i,j),
--							   enable => E, aclr => '0', aset => '0', aload => '0', sclr => '0', sset => '0', sload => '0');

                gr: my_rege generic map (N => B)
                    port map (clock => clock, resetn => '1', E => E, sclr => '0', D => RI(i,j), Q => RO(i,j) );							   
							   
			 end generate;
		gx: for i in 0 to N-2 generate -- rows				
				gp: my_mux2to1 generic map (N => B)
				    port map (A => AM(i,j), B => BM(i,j), S => s, O => RI(i,j));
		    end generate;
		
		Z(N-(j+1)) <= RO(0,j); -- output
	 end generate;

-- Setting up the connections:
gy: for i in 0 to N-1 generate -- rows
       gg: if (i /= N-1) generate -- From row 0 to N-1
		 		  AM(i,0) <= X(i);
				  BM(i,0) <= RO(i+1,0);
				  gz: for j in 1 to N-1 generate -- columns
						   AM(i,j) <= RO(i,j-1);
						   BM(i,j) <= RO(i+1,j);
					   end generate;
			  end generate;
			 
		 go: if (i = N-1) generate -- Only row N-1
				  RI(N-1,0) <= X(N-1);
				  gb: for j in 1 to N-1 generate
						   RI(N-1,j) <= RO(N-1,j-1);
					   end generate;
			  end generate;						
	 end generate;	 
	 
end structure;

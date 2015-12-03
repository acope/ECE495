---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

-- This hardware multiply two positive numbers of N bits.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_mult is
   generic (N: INTEGER:= 4);
	port (A,B: in std_logic_vector (N-1 downto 0);
	      P: out std_logic_vector (2*N-1 downto 0));
end my_mult;

architecture structure of my_mult is

	component fulladd
		port( cin, x, y : in std_logic;
				s, cout   : out std_logic);
	end component;

	type my_array is array (natural range <>, natural range <>) of std_logic;
	signal m: my_array(N downto 0, N-1 downto 0);
	signal s: my_array(N-1 downto 0, N-1 downto 0);
	signal c: my_array(N-1 downto 0, N-2 downto 0);
	
begin

-- Array of N * (N-1) full adders:	
	gi: for i in 0 to N-1 generate -- along rows
	      gj: for j in 0 to N-1 generate -- along columns
					   m(i,j) <= A(i) and B(j);
			         fa: if i /= N-1 and j /= N-1 generate
								 fij: fulladd port map (cin => c(i,j), x => s(i,j+1) , y => m(i+1,j), s => s(i+1,j),  cout => c(i+1,j));
							 end generate;
                  fb: if i = 0 generate
								 s(i,j) <= m(i,j);					
                     end generate;
				 end generate;			
		 end generate;
	
	m(N,0) <= '0';
	glj: for j in 0 to N-2 generate
			  c(0,j) <= '0';
			  s(j+1,N-1) <= m(j+1,N-1); -- Column 3 (from rows 1 to N-1)
			  P(j+1) <= s(j+1,0);
	        flj: fulladd port map  (cin => c(N-1,j), x => s(N-1,j+1), y => m(N,j), s => p(N+j) , cout => m(N,j+1));
		  end generate;		  
		  
   P(0) <= m(0,0);
	P(2*N-1) <= m(N,N-1);

end structure;




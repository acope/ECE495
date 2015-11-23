-- Here we declare components, functions, procedures, and types defined by the user
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use std.textio.all;
use ieee.std_logic_textio.all;

package pack_xtras is

	type std_logic_2d is array (NATURAL RANGE <>, NATURAL RANGE <>) of std_logic;
	
	type int_vector is array(natural range <>) of integer;
	
	function Get_X(LV,FB: in integer) return int_vector;
		
	function ceil_log2(dato: in integer) return integer;
	function length_fb(i,LO, L_fbk: in integer) return integer;
	function ceil_2(x: in integer) return integer; -- This function returns ceil(x/2)
	function ceil_a(x,a: in integer) return integer;  -- This function obtains ceil(x/a)
	function L_FIR_out(NH,B,N,NO,op: in integer) return integer;
	
	function get_M(N: in integer; symmetry: in string) return integer;	
	function size_in(B: in integer; symmetry: in string) return integer;
	
	function and_or_reducer(auxi: std_logic_vector) return std_logic;
	
	component LUTn
		generic (NH: INTEGER:= 12; -- number of bits of each of the h[n] values
					L: INTEGER:= 4; -- # of bits of Sb, i.e. we have a NL-input LUT
					BT: INTEGER:= 1; -- BT = '1' ==> Sb = SB (we take fB which is fb multiplied by -1), Bb = '0' ==> Sb /= SB (we do nothing)
					P:  INTEGER:= 8; -- pointer in the file, so that it takes the 2^NL values from position P as the fb's
											-- P: 1 --> M/NL
											-- Given P, the position in the file from which we start is:
											-- 2(P-1)(2^NL+1) + 1 + (2^NL + 1)BT
											-- P can be better understood as the number of filter block we are working on
											-- e.g.: P = 1 ==> we are working with the first filter block of NL coefficients	
					file_LUT: STRING:= "LUT_values.txt";
					USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.);											
		port (	ub: in std_logic_vector (L-1 downto 0); 
					fb: out std_logic_vector ( (NH + ceil_log2(L)) - 1 downto 0 ) -- NH + ceil_log2(NL): max # of bits for fb
				); 
	end component;
	
	component FIR_block
		generic (M:  INTEGER:= 32; -- number of nonrepetitive 'taps' = ceil (N/2), where N: # of taps
				size_I: INTEGER:= 9; -- size_I = B (nonsymmetry), size_I = B+1 (symmetry)
				NH: INTEGER:= 12; -- number of bits of each of the h[n] values
				L: INTEGER:= 4; -- # of bits of Sb, i.e. we have a L-input LUT
				P:  INTEGER:= 8; -- P: 1 --> M/L
										-- P can be better understood as the number of filter block we are working on
										-- e.g.: P = 1 ==> we are working with the first filter block of L coefficients
										-- Recall that each filter block has a different set of s[n] values, thus the LUT 
										-- values depend on each filter block are uniquely determined by P.
				
				L_fbk: INTEGER:= 33; -- output bits. This is supposed to be length_fb(ceil_log2(B+1), NH + ceil_log2(L))
				file_LUT: STRING:= "LUT_values.txt";
				USE_PRIM: STRING:= "YES"); -- "YES" --> use the ROM(2**L)x1 primitive,
				                           -- "NO" --> uses simple VHDL statement.);
		port (clock: in std_logic;
				U : in std_logic_vector; -- length is either 'NL*(B+1)' or 'NL*B' depending on symmetry
				y : out std_logic_vector (L_fbk - 1 downto 0));
	end component;
	
	component dffes
    Port ( d : in  STD_LOGIC;
	        clrn: in std_logic:= '1';
			  prn: in std_logic:= '1';
           clk : in  STD_LOGIC;
			  sclr: in std_logic; -- ena must be '1' for sclr to take effect
			  ena: in std_logic;
           q : out  STD_LOGIC);
	end component;

    component my_counter
    --	generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
        generic (COUNT: INTEGER:= 20); -- 
        port (clock, resetn: in std_logic;
              clk_en: in std_logic; -- clk_en = 1 -> all the other synchronous pins work!
                cnt_en, sclr: in std_logic; -- sclr = 1 -> Q = 0, cnt_en = 1 -> Q <= Q+1
                Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
                z: out std_logic); -- z = 1 when the maximum count (COUNT-1) has been reached
    end component;

    component my_shiftreg
       generic (N: INTEGER:= 8;
                 DIR: STRING:= "RIGHT"); -- only "LEFT", "RIGHT" are supported
        port ( clock, resetn: in std_logic;
               shiftin, E: in std_logic;
               Q: out std_logic_vector (N-1 downto 0);
              shiftout: out std_logic);
    end component;

	component my_mux2to1
		 generic (N: INTEGER:= 8 ); -- bit-width of the inputs
		 port (A, B : in std_logic_vector (N-1 downto 0);
				 S : in std_logic;
				 O : out std_logic_vector(N-1 downto 0));
	end component;
	
	component transp_array 
		generic (N: INTEGER:= 8;  -- Size of the matrix
					B: INTEGER:= 8); -- I/O bit-width
					
		port (	clock: in std_logic;
					Xi : in std_logic_vector (N*B -1 downto 0); -- works only for 8 DCT with even-odd decomposition
					E : in std_logic; -- enable for all the register chain
					s: in std_logic;
					Zo : out std_logic_vector (N*B - 1 downto 0));						
	end component;
	
	component my_addsub
        generic (N: INTEGER:= 4);
        port(   addsub   : in std_logic;
                x, y     : in std_logic_vector (N-1 downto 0);
                s        : out std_logic_vector (N-1 downto 0);
                overflow : out std_logic;
                cout     : out std_logic);
    end component;
	
	component my_rege
       generic (N: INTEGER:= 4);
        port ( clock, resetn: in std_logic;
               E, sclr: in std_logic; -- sclr: Synchronous clear
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0));
    end component;
    
end package pack_xtras;

package body pack_xtras is
    function Get_X(LV,FB: in integer) return int_vector is
        variable val : int_vector(LV downto 0);
    begin
        val(0) := FB; -- Dummy Level: Level 0 --> this is not a real level, but it useful to use it as Level 0
                      -- FB: number of summations to perform
        for i in 1 to LV loop
            val(i) := ceil_2(val(i-1));-- this function takes ceil(val(i-1)/2)
        end loop;
        
        return val;
    end function;
    
    function ceil_log2(dato: in integer) return integer is
        variable i, valor: integer;
    begin
        i:= 0; valor:= dato;
        while valor /= 1 loop
            valor := valor - (valor/2); -- 'valor/2' truncates the fractional part towards zero
            i:= i + 1;                    -- Ej.: 15/2 = 7
        end loop;
        return i;
    end function ceil_log2;
    
    function length_fb(i,LO, L_fbk: in integer) return integer is -- in FIR_block, it gives the # of bits for a signal at level 'i'
        variable result: integer;
    begin            
        result := LO + i + 2**i - 1;        
        if result > L_fbk then
            result:= L_fbk;
        end if;
        
        return result;
    end function length_fb;
    
    function ceil_2(x: in integer) return integer is -- This function obtains ceil(x/2)
        variable result: integer;
    begin
        if x rem 2 = 0 then -- if x is even?
            result:= x/2;
        else                     -- if x is odd
            result:= 1 + (x/2);
        end if;
        return result;
    end function ceil_2;
    
    function ceil_a(x,a: in integer) return integer is -- This function obtains ceil(x/a)
        variable result: integer;
    begin
       -- Recall: In VHDL, an operation x/a (x,a, integers) will always perform flooring operation
        if x rem a = 0 then -- if x is multiple of 'a'?
            result:= x/a;
        else                     -- if x is not multiple of 'a'?
            result:= 1 + (x/a);
        end if;
        return result;
    end function ceil_a;
    
    function L_FIR_out(NH,B,N,NO,op: in integer) return integer is
        variable result: integer;
    begin
    
        if op = 0 then
            result := NO;
        elsif op = 1 then
            result := NO;
        elsif op = 2 then
            result := NH+B + ceil_log2(N+1) - 1;
        else
            result := 0;
        end if;
        
        return result;
    
    end function L_FIR_out;
    
    function get_M(N: in integer; symmetry: in string) return integer is
        variable result: integer;
    begin
        if symmetry = "YES" or symmetry = "AYES" then
            result:= ceil_2(N); -- This function obtains ceil(N/2) -- number of nonrepetitive 'taps' = ceil (N/2), where N: # of taps
        else
            result:= N;
        end if;
        return result;
    end function get_M;
        
    function size_in(B: in integer; symmetry: in string) return integer is
        variable result: integer;
    begin
        if symmetry = "YES" or symmetry = "AYES" then
            result:= B+1;
        else
            result:= B;
        end if;
        return result;
    end function size_in;
    
    function and_or_reducer(auxi: std_logic_vector) return std_logic is
        variable result_and, result_or: std_logic;
    begin
        result_and:= '1'; result_or := '0';
        for i in auxi'range loop
            result_and:= result_and and auxi(i);
            result_or:= result_or or auxi(i);
        end loop;
        return result_and or not(result_or); -- if result_or = '0' or result_and = '1' then rall_1_or_0 = '1'
        
    end function and_or_reducer;
        
end package body pack_xtras;
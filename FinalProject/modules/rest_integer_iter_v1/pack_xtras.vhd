---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca.  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

-- Here we declare components, functions, procedures, and types defined by the user

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package pack_xtras is

	type std_logic_2d is array (NATURAL RANGE <>, NATURAL RANGE <>) of std_logic;
		
	type int_vector is array(natural range <>) of integer;
		
	function getNST(N,SW: in integer) return integer;
	function Get_X(LV,FB: in integer) return int_vector;
		
	function ceil_log2(dato: in integer) return integer;
	function length_fb(i,LO, L_fbk: in integer) return integer;
	function ceil_2(x: in integer) return integer;
	function L_FIR_out(NH,B,N,NO,op: in integer) return integer;
	function L_iFIR_out(NH,B,N,NO,op: in integer; mode: in string) return integer;
	
	function get_M(N: in integer; symmetry: in string) return integer;	
	function size_in(B: in integer; symmetry: in string) return integer;
	
	function and_or_reducer(auxi: std_logic_vector) return std_logic;
	
	component dffe
		port ( d : in  STD_LOGIC;
				clrn: in std_logic:= '1';
				prn: in std_logic:= '1';
				clk : in  STD_LOGIC;
				ena: in std_logic;
				q : out  STD_LOGIC);
	end component;
	
end package pack_xtras;

package body pack_xtras is
	
	function getNST(N,SW: in integer) return integer is
		variable val: integer;
	begin
		val := (N-1)/SW + 1; -- ceil (N/SW)
		return val;
	end function;
	
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
			i:= i + 1;					-- Ej.: 15/2 = 7
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
		else					 -- if x is odd
			result:= 1 + (x/2);
		end if;
		return result;
	end function ceil_2;
	
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
	
	function L_iFIR_out(NH,B,N,NO,op: in integer; mode: in string) return integer is
		variable result: integer;
	begin
	
		if op = 0 then
			result := NO;
		elsif op = 1 then
			result := NO;
		elsif op = 2 then
			if mode = "cIcH" then
				result := NH+B + ceil_log2(N+1) - 1 + 1; -- L_FIR + 1
			else
				result := NH+B + ceil_log2(N+1) - 1; -- L_FIR
			end if;
		else
			result := 0;
		end if;
		
		return result;
	
	end function L_iFIR_out;
	
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
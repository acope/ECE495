library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.pack_xtras.all;

-- Assumption: LUT_val has 256 positions of 8 bits.
entity LUT_NIto1 is
	generic ( NI: INTEGER:= 8;
			  data: in std_logic_vector;
			  USE_PRIM: STRING:= "YES"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
	port ( ILUT: in std_logic_vector (NI-1 downto 0);				
		   OLUT: out std_logic);
end LUT_NIto1;

architecture recursive of LUT_NIto1 is

    -- Vivado: If using recursive components, put it here (it's not enough to put it in libraries).
	component LUT_NIto1
		generic ( NI: INTEGER:= 8;
				  data: in std_logic_vector;
 			      USE_PRIM: STRING:= "YES"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement				  
		port (	ILUT: in std_logic_vector (NI-1 downto 0);				
				OLUT: out std_logic);
	end component;
	
	signal OLUT_l, OLUT_h: std_logic;
	
begin

p1: if USE_PRIM = "NO" generate
        OLUT <= data(conv_integer(ILUT));
    end generate;

-- Vivado 2015.2 Simulator (Behavioral): There are problems with primitives.
p2: if USE_PRIM = "YES" generate

        l4: if NI = 4 generate
                    ROM16X1_inst : ROM16X1 generic map (INIT => to_bitvector(data))
                    -- INIT = [INIT(15) INIT(14) .... INIT(0)]
                    -- A3A2A1A0 = "1111" --> O = INIT(15)
                    -- A3A2A1A0 = "0000" --> O = INIT(0)
                    port map (
                        O => OLUT,  -- ROM output
                        A0 => ILUT(0), -- ROM address[0]
                        A1 => ILUT(1), -- ROM address[1]
                        A2 => ILUT(2), -- ROM address[2]
                        A3 => ILUT(3));-- ROM address[3]
            end generate;
                                
        l5: if NI = 5 generate
                    ROM32X1_inst : ROM32X1 generic map (INIT => to_bitvector(data))
                    -- INIT = [INIT(31) INIT(30) .... INIT(0)]
                    -- A4A3A2A1A0 = "11111" --> O = INIT(31)
                    -- A4A3A2A1A0 = "00000" --> O = INIT(0)
                    port map (
                        O => OLUT,  -- ROM output
                        A0 => ILUT(0), -- ROM address[0]
                        A1 => ILUT(1), -- ROM address[1]
                        A2 => ILUT(2), -- ROM address[2]
                        A3 => ILUT(3), -- ROM address[3]
                        A4 => ILUT(4));-- ROM address[4]
            end generate;		
                                
        l6: if NI = 6 generate
                    ROM64X1_inst : ROM64X1 generic map (INIT => to_bitvector(data))
                    -- INIT = [INIT(63) INIT(62) .... INIT(0)]
                    -- A5A4A3A2A1A0 = "111111" --> O = INIT(63)
                    -- A5A4A3A2A1A0 = "000000" --> O = INIT(0)
                    port map (
                        O => OLUT,  -- ROM output
                        A0 => ILUT(0), -- ROM address[0]
                        A1 => ILUT(1), -- ROM address[1]
                        A2 => ILUT(2), -- ROM address[2]
                        A3 => ILUT(3), -- ROM address[3]
                        A4 => ILUT(4), -- ROM address[4]
                        A5 => ILUT(5));-- ROM address[5]
             end generate;
                                
        l7: if NI = 7 generate
                    ROM128X1_inst : ROM128X1 generic map (INIT => to_bitvector(data))
                    -- INIT = [INIT(127) INIT(126) .... INIT(0)]
                    -- A6A5A4A3A2A1A0 = "1111111" --> O = INIT(127)
                    -- A6A5A4A3A2A1A0 = "0000000" --> O = INIT(0)
                    port map (
                        O => OLUT,  -- ROM output
                        A0 => ILUT(0), -- ROM address[0]
                        A1 => ILUT(1), -- ROM address[1]
                        A2 => ILUT(2), -- ROM address[2]
                        A3 => ILUT(3), -- ROM address[3]
                        A4 => ILUT(4), -- ROM address[4]
                        A5 => ILUT(5), -- ROM address[5]
                        A6 => ILUT(6));-- ROM address[6]
             end generate;
                                
        l8: if NI = 8 generate
                    ROM256X1_inst : ROM256X1 generic map (INIT => to_bitvector(data))
                    -- INIT = [INIT(255) INIT(254) .... INIT(0)]
                    -- A7A6A5A4A3A2A1A0 = "11111111" --> O = INIT(255)
                    -- A7A6A5A4A3A2A1A0 = "00000000" --> O = INIT(0)
                    port map (
                        O => OLUT,  -- ROM output
                        A0 => ILUT(0), -- ROM address[0]
                        A1 => ILUT(1), -- ROM address[1]
                        A2 => ILUT(2), -- ROM address[2]
                        A3 => ILUT(3), -- ROM address[3]
                        A4 => ILUT(4), -- ROM address[4]
                        A5 => ILUT(5), -- ROM address[5]
                        A6 => ILUT(6), -- ROM address[6]
                        A7 => ILUT(7));-- ROM address[7]
             end generate;
                   
             
        l9: if NI >= 9 generate
                    ra: LUT_NIto1 generic map (NI => NI-1, data => data(2**(NI-1) - 1 downto 0))
                        port map (ILUT => ILUT(NI-2 downto 0), OLUT => OLUT_l);
                    rb: LUT_NIto1 generic map (NI => NI-1, data => data(2**NI - 1 downto 2**(NI-1)))
                        port map (ILUT => ILUT(NI-2 downto 0), OLUT => OLUT_h);	 
                         
                    with ILUT(NI-1) select
                            OLUT <= OLUT_l when '0',
                                      OLUT_h when '1',
                                      '0' when others;
             end generate;
    end generate;
end recursive;
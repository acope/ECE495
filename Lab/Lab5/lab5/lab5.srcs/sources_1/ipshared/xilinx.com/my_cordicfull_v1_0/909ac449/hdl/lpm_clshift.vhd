---START_ENTITY_HEADER---------------------------------------------------------
--
-- Entity Name     :  lpm_clshift
--
-- Description     :  Parameterized combinatorial logic shifter or barrel shifter
--                    megafunction.
--
-- Limitation      :  n/a
--
-- results Expected:  Return the shifted data and underflow/overflow status bit.
--
---END_ENTITY_HEADER-----------------------------------------------------------

-- LIBRARY USED----------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

-- ENTITY DECLARATION
entity LPM_CLSHIFT is

-- GENERIC DECLARATION
    generic (
        lpm_width     : natural;    -- Width of the data[] and result[] ports.
                                    -- MUST be greater than 0 (Required)                                    
        lpm_widthdist : natural;    -- Width of the distance[] input port.
                                    -- MUST be greater than 0 (Required)
        lpm_shifttype : string := "LOGICAL"; -- Type of shifting operation to be performed.
        lpm_type      : string := "LPM_CLSHIFT";
        lpm_hint      : string := "UNUSED"
    );

-- PORT DECLARATION 
    port (
        -- data to be shifted. (Required)
        data      : in STD_LOGIC_VECTOR(lpm_width-1 downto 0); 
        -- Number of positions to shift data[] in the direction specified by the
        -- direction port. (Required)
        distance  : in STD_LOGIC_VECTOR(lpm_widthdist-1 downto 0); 
        -- direction of shift. Low = left (toward the MSB), high = right (toward the LSB). 
        direction : in STD_LOGIC := '0';
        -- Shifted data. (Required)
        result    : out STD_LOGIC_VECTOR(lpm_width-1 downto 0);
        -- Logical or arithmetic underflow.
        underflow : out STD_LOGIC;
        -- Logical or arithmetic overflow.
        overflow  : out STD_LOGIC
    );
end LPM_CLSHIFT;
-- END OF ENTITY

-- BEGINNING OF ARCHITECTURE
architecture LPM_SYN of LPM_CLSHIFT is

-- SIGNAL DECLARATION
signal i_result : std_logic_vector(lpm_width-1 downto 0);

begin

-- PROCESS DECLARATION

    -- basic error checking for invalid parameters
--    MSG: process
--    begin
--        if (lpm_width <= 0) then
--            ASSERT FALSE
--            REPORT "Value of lpm_width parameter must be greater than 0!"
--            SEVERITY ERROR;
--        end if;
--        if (lpm_widthdist <= 0) then
--            ASSERT FALSE
--            REPORT "Value of lpm_widthdist parameter must be greater than 0!"
--            SEVERITY ERROR;
--        end if;   
--        wait;
--    end process MSG;


    -- Get the shifted data
    process(data, distance, direction)
    variable tmpdata : std_logic_vector(lpm_width-1 downto 0);
    variable tmpdist : integer;
    begin
        if ((lpm_shifttype = "ARITHMETIC") or (lpm_shifttype = "LOGICAL")) then
            tmpdata := conv_std_logic_vector(unsigned(data), lpm_width);
            tmpdist := conv_integer(unsigned(distance));
            for i in lpm_width-1 downto 0 loop
                if (direction = '0') then
                    if (i >= tmpdist) then
                        i_result(i) <= tmpdata(i-tmpdist);
                    else
                        i_result(i) <= '0';
                    end if;
                elsif (direction = '1') then
                    if ((i+tmpdist) < lpm_width) then
                        i_result(i) <= tmpdata(i+tmpdist);
                    elsif (lpm_shifttype = "ARITHMETIC") then
                        i_result(i) <= data(lpm_width-1);
                    else
                        i_result(i) <= '0';
                    end if;
                end if;
            end loop;
        elsif (lpm_shifttype = "ROTATE") then
            tmpdata := conv_std_logic_vector(unsigned(data), lpm_width);
            tmpdist := conv_integer(unsigned(distance)) mod lpm_width;
            for i in lpm_width-1 downto 0 loop
                if (direction = '0') then
                    if (i >= tmpdist) then
                        i_result(i) <= tmpdata(i-tmpdist);
                    else
                        i_result(i) <= tmpdata(i+lpm_width-tmpdist);
                    end if;
                elsif (direction = '1') then
                    if (i+tmpdist < lpm_width) then
                        i_result(i) <= tmpdata(i+tmpdist);
                    else
                        i_result(i) <= tmpdata(i-lpm_width+tmpdist);
                    end if;
                end if;
            end loop;
        else
            ASSERT FALSE
            REPORT "Illegal lpm_shifttype property value for LPM_CLSHIFT!"
            SEVERITY ERROR;
        end if;
    end process;

    -- Get the overflow/underflow status bit.
    process(data, distance, direction, i_result)
    variable neg_one : signed(lpm_width-1 downto 0) := (OTHERS => '1');
    variable tmpdata : std_logic_vector(lpm_width-1 downto 0);
    variable tmpdist : integer;
    variable msb_cnt : integer := 0;
    variable lsb_cnt : integer := 0;
    variable sgn_bit : std_logic;
    begin
        tmpdata := conv_std_logic_vector(unsigned(data), lpm_width);
        tmpdist := conv_integer(distance);

        overflow <= '0';
        underflow <= '0';

        if ((tmpdist /= 0) and (tmpdata /= 0)) then
            if (lpm_shifttype = "ROTATE") then
                overflow <= 'U';
                underflow <= 'U';
            else
                if (tmpdist < lpm_width) then
                    if (lpm_shifttype = "LOGICAL") then
                        msb_cnt := 0;
                        while ((msb_cnt < lpm_width) and
                                (tmpdata(lpm_width-msb_cnt-1) = '0')) loop
                            msb_cnt := msb_cnt + 1;
                        end loop;

                        if ((tmpdist > msb_cnt) and (direction = '0')) then
                            overflow <= '1';
                        elsif ((tmpdist + msb_cnt >= lpm_width) and (direction = '1')) then
                            underflow <= '1';
                        end if;
                    elsif (lpm_shifttype = "ARITHMETIC") then
                        sgn_bit := '0';
                        if (tmpdata(lpm_width-1) = '1') then
                            sgn_bit := '1';
                        end if;

                        msb_cnt := 0;
                        while ((msb_cnt < lpm_width) and
                                (tmpdata(lpm_width-msb_cnt-1) = sgn_bit)) loop
                            msb_cnt := msb_cnt + 1;
                        end loop;

                        lsb_cnt := 0;
                        while ((lsb_cnt < lpm_width) and (tmpdata(lsb_cnt) = '0')) loop
                            lsb_cnt := lsb_cnt + 1;
                        end loop;

                        if (direction = '1') then         -- shift right
                            if (tmpdata(lpm_width-1) = '1') then  -- negative
                                if ((msb_cnt + tmpdist >= lpm_width) and 
                                    (msb_cnt /= lpm_width)) then
                                    underflow <= '1';
                                end if;
                            else  -- non-neg
                                if (((msb_cnt + tmpdist) >= lpm_width) and
                                    (msb_cnt /= lpm_width)) then
                                    underflow <= '1';
                                end if;
                            end if;
                        elsif (direction = '0') then      -- shift left
                            if (tmpdata(lpm_width-1) = '1') then -- negative
                                if (((signed(tmpdata) /= neg_one) and
                                    (tmpdist >= lpm_width)) or (tmpdist >= msb_cnt)) then
                                    overflow <= '1';
                                end if;
                            else  -- non-neg
                                if (((tmpdata /= 0) and (tmpdist >= lpm_width-1)) or
                                    (tmpdist >= msb_cnt)) then
                                    overflow <= '1';
                                end if;
                            end if;
                        end if;
                    end if;
                else
                    if (direction = '0') then
                        overflow <= '1';
                    elsif (direction = '1') then
                        underflow <= '1';
                    end if;
                end if;  -- tmpdist < lpm_width
            end if;  -- lpm_shifttype = "ROTATE"
        end if;  -- tmpdist /= 0 and tmpdata /= 0
    end process;

    result <= i_result;

end LPM_SYN;
-- END OF ARCHITECTURE
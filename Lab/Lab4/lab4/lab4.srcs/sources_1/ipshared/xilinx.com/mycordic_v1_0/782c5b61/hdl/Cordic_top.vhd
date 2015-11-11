----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2015 04:23:00 PM
-- Design Name: 
-- Module Name: Cordic_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Cordic_top is
  Port (S_AXI_ACLK : in std_logic;
        slv_reg0 : in std_logic_vector(31 downto 0);
        slv_reg1 : in std_logic_vector(31 downto 0);
        slv_reg2 : out std_logic_vector(31 downto 0);
        slv_reg3 : out std_logic_vector(31 downto 0);
        S_AXI_ARESETN  : in std_logic;
        slv_reg_wren : in std_logic
        );

end Cordic_top;

architecture Behavioral of Cordic_top is
component CORDIC_FP_top 
	port ( clock, reset, s, mode: in std_logic;
		   Xin, Yin, Zin: in std_logic_vector (15 downto 0);
		   done: out std_logic;
		   Xout, Yout, Zout: out std_logic_vector (15 downto 0)
		   );
end component;
--State Machine Definitions
--type state is (S1, S2);
--  signal state_y: state:=S1;
--  signal E: std_logic;
 signal resets: std_logic; 
begin
--Dont need the state machine??? FIXME
--  process (S_AXI_ARESETN, S_AXI_ACLK, E, slv_reg_wren)
--    begin
--            if S_AXI_ARESETN = '0' then -- asynchronous signal
--                state_y <= S1; -- if resetn asserted, go to initial state: S1
--                E <= '0';
--            elsif (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          
--                case state_y is
--                    when S1 => if slv_reg_wren = '1' then E<= '1'; state_y <= S2; else state_y <= S1; end if;
--                    when S2 => if  slv_reg_wren = '1' then E<= '0'; state_y <= S1; else state_y <= S2; end if;
                    
--                end case;
--            end if;
--    end process;
resets <= not(S_AXI_ARESETN);

cordic : CORDIC_FP_top 
	port map ( clock => S_AXI_ACLK,
	           reset => resets,
	           --s => E,
	           s => slv_reg1(14),
	           mode => slv_reg1(15),
		       Xin => slv_reg0(15 downto 0),
		       Yin => slv_reg0(31 downto 16),
		       Zin => slv_reg1(31 downto 16),
		       done => slv_reg3(15),
		       Xout => slv_reg2(15 downto 0),
		       Yout => slv_reg2(31 downto 16),
		       Zout => slv_reg3(31 downto 16) 
		     );


end Behavioral;

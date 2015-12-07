
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Grayscale_AXI_Top is
    generic(P: integer:= 8);
    Port (S_AXI_ACLK : in std_logic;
          slv_reg0 : in std_logic_vector(31 downto 0);
          slv_reg1 : out std_logic_vector(31 downto 0);
          S_AXI_ARESETN  : in std_logic;
          slv_reg_wren : in std_logic );
end Grayscale_AXI_Top;

architecture Behavioral of Grayscale_AXI_Top is

    component Grayscale_Top is
        Generic(P: integer:= 8);
        Port (RGBin: in std_logic_vector(P-1 downto 0);
              Rp,Gp,Bp: in std_logic_vector(P-1 downto 0);
              start,clock,resetn:in std_logic;
              RGBout: out std_logic_vector(P-1 downto 0);
              done: out std_logic);
    end component Grayscale_Top;

    --State Machine Definitions
    type state is (S1, S2);
      signal state_y: state:=S1;
      signal E: std_logic;

begin

      process (S_AXI_ARESETN, S_AXI_ACLK, E, slv_reg_wren)
        begin
                if S_AXI_ARESETN = '0' then -- asynchronous signal
                    state_y <= S1; -- if resetn asserted, go to initial state: S1
                    E <= '0';
                elsif (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              
                    case state_y is
                        when S1 => if slv_reg_wren = '1' then E<= '1'; state_y <= S2; else state_y <= S1; end if;
                        when S2 => if  slv_reg_wren = '1' then E<= '0'; state_y <= S1; else state_y <= S2; end if;
                        
                    end case;
                end if;
        end process;


        grayness: Grayscale_Top
        Generic map(P => P)
        Port map(RGBin => slv_reg0(31 downto 24), Rp => slv_reg0(23 downto 16),Gp => slv_reg0(15 downto 8),Bp => slv_reg0(7 downto 0),
              start => E,clock => S_AXI_ACLK,resetn => S_AXI_ARESETN, RGBout => slv_reg1(31 downto 24), done => slv_reg1(23));

end Behavioral;

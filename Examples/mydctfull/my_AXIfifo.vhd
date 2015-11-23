library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

Library UNISIM;
use UNISIM.vcomponents.all;

entity my_AXIfifo is
	generic (
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
	    -- Global Clock Signal
        S_AXI_ACLK    : in std_logic;
        -- Global Reset Signal. This Signal is Active LOW
        S_AXI_ARESETN : in std_logic;	
		-- Write valid. This signal indicates that valid write data and strobes are available.
        S_AXI_WVALID  : in std_logic;
        -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe
        -- bit for each eight bits of the write data bus.
        S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);        
	    -- Write ready. This signal indicates that the slave can accept the write data.
        S_AXI_WREADY    : in std_logic;

        -- Read ready. This signal indicates that the master can accept the read data and response information.
        S_AXI_RREADY    : in std_logic;        
		-- Read valid. This signal indicates that the channel is signaling the required read data.
        S_AXI_RVALID  : out std_logic;  
        -- Read response. This signal indicates the status of the read transfer.
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
                              
	    -- Write Data
        S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read Data
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);            
        
	    -- The axi_awv_awr_flag flag marks the presence of write address valid
        axi_awv_awr_flag : in std_logic;
        --The axi_arv_arr_flag flag marks the presence of read address valid
        axi_arv_arr_flag : in std_logic
        );
end my_AXIfifo;

architecture arch_imp of my_AXIfifo is

    signal axi_rvalid : std_logic;
    signal axi_rresp  : std_logic_vector(1 downto 0);
    
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;

	signal mem_rden : std_logic;
    signal mem_wren : std_logic;
	
	------------------------------------------------------------------------
	type state is (S1, S2);	
    signal y_fx, y: state; 
    signal clkfx: std_logic;
    signal rst: std_logic;
    
    -- Input FIFO signals
    signal irden, iwren: std_logic;
    signal ififo_DI, ififo_DO: std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
    signal iempty, ifull: std_logic;

    -- Output FIFO signals
    signal orden, owren: std_logic;
    signal ofifo_DI, ofifo_DO: std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
    signal oempty, ofull: std_logic;

    signal fifo_fsm_rstq, fifo_fsm_rst, sclrC, EC, zC: std_logic;
    
    component dct_ip is
        generic (PLBW: INTEGER:= 32; -- only one supported so far,
                          --    if PLBW=64, the interface will need modifications (especially for case 4x4)
                    N: INTEGER:= 8;  -- DCT size (4,8,16)
                    NH: INTEGER:= 16;
                    B: INTEGER:= 8;
                    NO: INTEGER:= 16;    
                    NQ: INTEGER:=15;
                    USE_PRIM: STRING:= "YES";
                    IMPLEMENTATION: STRING:= "fullypip");
        port (    clock: in std_logic;
                    rst: in std_logic; -- high-level reset                
                    DI: in std_logic_vector (31 downto 0);
                    DO: out std_logic_vector (31 downto 0);
                    ofull, iempty: in std_logic;
                    owren, irden: out std_logic);                
    end component;
    
    component my_genpulse_sclr
        --generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
        generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
        port (clock, resetn, E, sclr: in std_logic;
                Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
                z: out std_logic);
    end component;
    
    -- *******************************************************
    -- Constants for IP
    constant N: INTEGER:= 4; -- DCT size 4,8,16
    constant NH: INTEGER:= 16; -- Coefficients' bit-width    (10,12,14,16)
    constant NO: INTEGER:= 16; -- 8, 10,12, 14,16 are supported to work
    constant NQ: INTEGER:= NO-1;    
    constant B: INTEGER:= 8; -- Input bit-width (8) --> this interface has only been tested for B=8.    
    constant USE_PRIM: STRING:= "YES";
    --constant IMPLEMENTATION: STRING:= "fullypip"; -- fullypip, onetrans
    constant IMPLEMENTATION: STRING:= "onetrans"; -- fullypip, onetrans
    
begin

a1: assert (C_S_AXI_DATA_WIDTH = 32 or C_S_AXI_DATA_WIDTH = 64)
    report "Width of AXI bus can only be 32 or 64!"
	severity error;
	 
    mem_wren <= S_AXI_WREADY and S_AXI_WVALID ;
    mem_rden <= axi_arv_arr_flag ;
    clkfx <= S_AXI_ACLK;
    --rst <= not (S_AXI_ARESETN);
    
    S_AXI_RDATA <= oFIFO_DO;
    iFIFO_DI <= S_AXI_WDATA;
    
    -- ********* IP *********************************************************************************************
    -- 2D DCT
     -- PLBW: number of bits of the interface. Here we use 32 bits for AXI interface
     --       we might need to change to BUSW instead (this is a cosmetic change for later)
    ji: dct_ip generic map (PLBW => 32, N => N, NH => NH, B => B, NO => NO, NQ => NQ, USE_PRIM => USE_PRIM, IMPLEMENTATION => IMPLEMENTATION)
        port map (clock => clkfx, rst => rst, DI => iFIFO_DO, DO => oFIFO_DI, ofull => ofull, iempty => iempty, owren => owren, irden => irden);
    -- *******************************************************************************************************
        
	-- Implement axi_arvalid generation
        -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
        -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
        -- data are available on the axi_rdata bus at this instance. The 
        -- assertion of axi_rvalid marks the validity of read data on the 
        -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
        -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
        -- cleared to zero on reset (active low).  
        S_AXI_RVALID <= axi_rvalid;
        S_AXI_RRESP    <= axi_rresp;
        process (S_AXI_ARESETN, S_AXI_ACLK, axi_arv_arr_flag, axi_rvalid, oempty)
        begin
          if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
              axi_rvalid <= '0';
              axi_rresp  <= "00";
            else
              if (axi_arv_arr_flag = '1' and axi_rvalid = '0' and oempty='0') then -- The axi_arv_arr_flag flag marks the presence of read address valid, i.e., we are ready to read
                axi_rvalid <= '1';
                axi_rresp  <= "00"; -- 'OKAY' response
              elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
                axi_rvalid <= '0';
              end  if;      
            end if;
          end if;
        end process;
 
-- External control (AXI):
-- Finite State Machine (at S_AXI_ACLK clock):
-- ----------------------------------------------
flipf: process (S_AXI_ACLK, S_AXI_ARESETN, fifo_fsm_rst)
	begin
	    if S_AXI_ARESETN = '0' then
	       fifo_fsm_rstq <= '0';
		elsif (S_AXI_ACLK'event and S_AXI_ACLK='1') then
			fifo_fsm_rstq <= fifo_fsm_rst;
		end if;		
	end process;

rst <= fifo_fsm_rstq or not(S_AXI_ARESETN);

c1: my_genpulse_sclr generic map (COUNT => 16)
    port map (clock => S_AXI_ACLK, resetn => S_AXI_ARESETN, E => EC, sclr => sclrC, z => zC);
    
   Transitions: process (S_AXI_ARESETN, S_AXI_ACLK, oempty, zC)
	begin
		if S_AXI_ARESETN = '0' then
			y <= S1;
		elsif (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
			case y is
				when S1 =>
				    if zC = '1' then -- C = 15?
				        if oempty = '1' then y <= S2; else y <= S1; end if;
				    else
				        y <= S1;
				    end if;				
				when S2 =>
					y <= S2;
			end case;
		end if;
	end process;

	Outputs: process(y, mem_wren, mem_rden, ifull, oempty, zC, axi_rvalid)
	begin
		-- Initialization of signals:
		iwren <= '0'; orden <= '0'; sclrC <= '0'; EC <= '0'; fifo_fsm_rst <= '0';
		case y is
			when S1 =>
			     if zC = '1' then -- C = 15?
			         sclrC <= '1';
			     else
			         fifo_fsm_rst <= '1';
			         EC <= '1'; -- C <= C+1
			     end if;
			
			when S2 =>
				if (mem_wren = '1') then
					if ifull = '0' then iwren <= '1'; end if;
				else
					if mem_rden = '1' then
						if oempty = '0' and axi_rvalid = '1' then orden <= '1'; end if; --
					end if;
				end if;
				
		end case;
	end process;	 

ififo_DI <= S_AXI_WDATA; -- Input of input FIFO gets data from the PLB
S_AXI_RDATA <= ofifo_DO; -- Output of output FIFO writes on the PLB

-- Input FIFO:
-- **************
ta: if C_S_AXI_DATA_WIDTH = 32 generate
       FIFO18E1_inst : FIFO18E1
       generic map (
          ALMOST_EMPTY_OFFSET => X"0080",   -- Sets the almost empty threshold
          ALMOST_FULL_OFFSET => X"0080",    -- Sets almost full threshold
          DATA_WIDTH => 36,                  -- Sets data width to 4-36
          DO_REG => 1,                      -- Enable output register (1-0) Must be 1 if EN_SYN = FALSE
          EN_SYN => FALSE,                  -- Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
          FIFO_MODE => "FIFO18_36",            -- Sets mode to FIFO18 or FIFO18_36
          FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to FALSE, TRUE
          INIT => X"000000000",             -- Initial values on output port
          SIM_DEVICE => "7SERIES",          -- Must be set to "7SERIES" for simulation behavior
          SRVAL => X"000000000"             -- Set/Reset value for output port
       )
       port map (
          -- Read Data: 32-bit (each) output: Read output data
          DO => iFIFO_DO,                   -- 32-bit output: Data output
          --DOP => DOP,                 -- 4-bit output: Parity data output
          -- Status: 1-bit (each) output: Flags and other FIFO status outputs
          --ALMOSTEMPTY => ALMOSTEMPTY, -- 1-bit output: Almost empty flag
          --ALMOSTFULL => ALMOSTFULL,   -- 1-bit output: Almost full flag
          EMPTY => iempty,             -- 1-bit output: Empty flag
          FULL => ifull,               -- 1-bit output: Full flag
          --RDCOUNT => RDCOUNT,         -- 12-bit output: Read count
          --RDERR => RDERR,             -- 1-bit output: Read error
          --WRCOUNT => WRCOUNT,         -- 12-bit output: Write count
          --WRERR => WRERR,             -- 1-bit output: Write error
          -- Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
          RDCLK => clkfx,             -- 1-bit input: Read clock
          RDEN => irden,               -- 1-bit input: Read enable
          REGCE => '1',             -- 1-bit input: Clock enable
          RST => rst,                 -- 1-bit input: Asynchronous Reset
          RSTREG => '0',           -- 1-bit input: Output register set/reset
          -- Write Control Signals: 1-bit (each) input: Write clock and enable input signals
          WRCLK => S_AXI_ACLK,             -- 1-bit input: Write clock
          WREN => iwren,               -- 1-bit input: Write enable
          -- Write Data: 32-bit (each) input: Write input data
          DI => iFIFO_DI,                   -- 32-bit input: Data input
          DIP => "0000"                  -- 4-bit input: Parity input
       );
   end generate;
   	
tb: if C_S_AXI_DATA_WIDTH = 64 generate        
           FIFO36E1_inst : FIFO36E1
           generic map (
              ALMOST_EMPTY_OFFSET => X"0080",   -- Sets the almost empty threshold
              ALMOST_FULL_OFFSET => X"0080",    -- Sets almost full threshold
              DATA_WIDTH => 72,                  -- Sets data width to 4-72
              DO_REG => 1,                      -- Enable output register (1-0) Must be 1 if EN_SYN = FALSE
              EN_ECC_READ => FALSE,             -- Enable ECC decoder, FALSE, TRUE
              EN_ECC_WRITE => FALSE,            -- Enable ECC encoder, FALSE, TRUE
              EN_SYN => FALSE,                  -- Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
              FIFO_MODE => "FIFO36_72",            -- Sets mode to "FIFO36" or "FIFO36_72" 
              FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to FALSE, TRUE
              INIT => X"000000000000000000",    -- Initial values on output port
              SIM_DEVICE => "7SERIES",          -- Must be set to "7SERIES" for simulation behavior
              SRVAL => X"000000000000000000"    -- Set/Reset value for output port
           )
           port map (
              -- ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
              --DBITERR => DBITERR,             -- 1-bit output: Double bit error status
              --ECCPARITY => ECCPARITY,         -- 8-bit output: Generated error correction parity
              --SBITERR => SBITERR,             -- 1-bit output: Single bit error status
              -- Read Data: 64-bit (each) output: Read output data
              DO => ififo_DO,                       -- 64-bit output: Data output
              --DOP => DOP,                     -- 8-bit output: Parity data output
              -- Status: 1-bit (each) output: Flags and other FIFO status outputs
              --ALMOSTEMPTY => ALMOSTEMPTY,     -- 1-bit output: Almost empty flag
              --ALMOSTFULL => ALMOSTFULL,       -- 1-bit output: Almost full flag
              EMPTY => iempty,                 -- 1-bit output: Empty flag
              FULL => ifull,                   -- 1-bit output: Full flag
              --RDCOUNT => RDCOUNT,             -- 13-bit output: Read count
              --RDERR => RDERR,                 -- 1-bit output: Read error
              --WRCOUNT => WRCOUNT,             -- 13-bit output: Write count
              --WRERR => WRERR,                 -- 1-bit output: Write error
              -- ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
              INJECTDBITERR => '0', -- 1-bit input: Inject a double bit error input
              INJECTSBITERR => '0',
              -- Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
              RDCLK => clkfx,                 -- 1-bit input: Read clock
              RDEN => irden,                   -- 1-bit input: Read enable
              REGCE => '1',                 -- 1-bit input: Clock enable
              RST => rst,                     -- 1-bit input: Reset
              RSTREG => '0',               -- 1-bit input: Output register set/reset
              -- Write Control Signals: 1-bit (each) input: Write clock and enable input signals
              WRCLK => S_AXI_ACLK,                 -- 1-bit input: Rising edge write clock.
              WREN => iwren,                   -- 1-bit input: Write enable
              -- Write Data: 64-bit (each) input: Write input data
              DI => iFIFO_DI,                       -- 64-bit input: Data input
              DIP => "00000000"                     -- 8-bit input: Parity input
           );			
     end generate;

-- Output FIFO:
-- **************
xa: if C_S_AXI_DATA_WIDTH = 32 generate
       FIFO18E1_inst : FIFO18E1
       generic map (
          ALMOST_EMPTY_OFFSET => X"0080",   -- Sets the almost empty threshold
          ALMOST_FULL_OFFSET => X"0080",    -- Sets almost full threshold
          DATA_WIDTH => 36,                  -- Sets data width to 4-36
          DO_REG => 1,                      -- Enable output register (1-0) Must be 1 if EN_SYN = FALSE
          EN_SYN => FALSE,                  -- Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
          FIFO_MODE => "FIFO18_36",            -- Sets mode to FIFO18 or FIFO18_36
          FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to FALSE, TRUE
          INIT => X"000000000",             -- Initial values on output port
          SIM_DEVICE => "7SERIES",          -- Must be set to "7SERIES" for simulation behavior
          SRVAL => X"000000000"             -- Set/Reset value for output port
       )
       port map (
          -- Read Data: 32-bit (each) output: Read output data
          DO => oFIFO_DO,                   -- 32-bit output: Data output
          --DOP => DOP,                 -- 4-bit output: Parity data output
          -- Status: 1-bit (each) output: Flags and other FIFO status outputs
          --ALMOSTEMPTY => ALMOSTEMPTY, -- 1-bit output: Almost empty flag
          --ALMOSTFULL => ALMOSTFULL,   -- 1-bit output: Almost full flag
          EMPTY => oempty,             -- 1-bit output: Empty flag
          FULL => ofull,               -- 1-bit output: Full flag
          --RDCOUNT => RDCOUNT,         -- 12-bit output: Read count
          --RDERR => RDERR,             -- 1-bit output: Read error
          --WRCOUNT => WRCOUNT,         -- 12-bit output: Write count
          --WRERR => WRERR,             -- 1-bit output: Write error
          -- Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
          RDCLK => S_AXI_ACLK,             -- 1-bit input: Read clock
          RDEN => orden,               -- 1-bit input: Read enable
          REGCE => '1',             -- 1-bit input: Clock enable
          RST => rst,                 -- 1-bit input: Asynchronous Reset
          RSTREG => '0',           -- 1-bit input: Output register set/reset
          -- Write Control Signals: 1-bit (each) input: Write clock and enable input signals
          WRCLK => clkfx,             -- 1-bit input: Write clock
          WREN => owren,               -- 1-bit input: Write enable
          -- Write Data: 32-bit (each) input: Write input data
          DI => oFIFO_DI,                   -- 32-bit input: Data input
          DIP => "0000"                  -- 4-bit input: Parity input
       );
   end generate;
   	
xb: if C_S_AXI_DATA_WIDTH = 64 generate        
           FIFO36E1_inst : FIFO36E1
           generic map (
              ALMOST_EMPTY_OFFSET => X"0080",   -- Sets the almost empty threshold
              ALMOST_FULL_OFFSET => X"0080",    -- Sets almost full threshold
              DATA_WIDTH => 72,                  -- Sets data width to 4-72
              DO_REG => 1,                      -- Enable output register (1-0) Must be 1 if EN_SYN = FALSE
              EN_ECC_READ => FALSE,             -- Enable ECC decoder, FALSE, TRUE
              EN_ECC_WRITE => FALSE,            -- Enable ECC encoder, FALSE, TRUE
              EN_SYN => FALSE,                  -- Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
              FIFO_MODE => "FIFO36_72",            -- Sets mode to "FIFO36" or "FIFO36_72" 
              FIRST_WORD_FALL_THROUGH => TRUE, -- Sets the FIFO FWFT to FALSE, TRUE
              INIT => X"000000000000000000",    -- Initial values on output port
              SIM_DEVICE => "7SERIES",          -- Must be set to "7SERIES" for simulation behavior
              SRVAL => X"000000000000000000"    -- Set/Reset value for output port
           )
           port map (
              -- ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
              --DBITERR => DBITERR,             -- 1-bit output: Double bit error status
              --ECCPARITY => ECCPARITY,         -- 8-bit output: Generated error correction parity
              --SBITERR => SBITERR,             -- 1-bit output: Single bit error status
              -- Read Data: 64-bit (each) output: Read output data
              DO => ofifo_DO,                       -- 64-bit output: Data output
              --DOP => DOP,                     -- 8-bit output: Parity data output
              -- Status: 1-bit (each) output: Flags and other FIFO status outputs
              --ALMOSTEMPTY => ALMOSTEMPTY,     -- 1-bit output: Almost empty flag
              --ALMOSTFULL => ALMOSTFULL,       -- 1-bit output: Almost full flag
              EMPTY => oempty,                 -- 1-bit output: Empty flag
              FULL => ofull,                   -- 1-bit output: Full flag
              --RDCOUNT => RDCOUNT,             -- 13-bit output: Read count
              --RDERR => RDERR,                 -- 1-bit output: Read error
              --WRCOUNT => WRCOUNT,             -- 13-bit output: Write count
              --WRERR => WRERR,                 -- 1-bit output: Write error
              -- ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
              INJECTDBITERR => '0', -- 1-bit input: Inject a double bit error input
              INJECTSBITERR => '0',
              -- Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
              RDCLK => S_AXI_ACLK,                 -- 1-bit input: Read clock
              RDEN => orden,                   -- 1-bit input: Read enable
              REGCE => '1',                 -- 1-bit input: Clock enable
              RST => rst,                     -- 1-bit input: Reset
              RSTREG => '0',               -- 1-bit input: Output register set/reset
              -- Write Control Signals: 1-bit (each) input: Write clock and enable input signals
              WRCLK => clkfx,                 -- 1-bit input: Rising edge write clock.
              WREN => owren,                   -- 1-bit input: Write enable
              -- Write Data: 64-bit (each) input: Write input data
              DI => oFIFO_DI,                       -- 64-bit input: Data input
              DIP => "00000000"                     -- 8-bit input: Parity input
           );			
     end generate;
end arch_imp;

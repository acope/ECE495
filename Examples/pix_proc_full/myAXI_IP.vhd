library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myAXI_IP is
	generic (
	    TYPO: STRING:="PIXO"; -- MEMO, PIXO, FIFO
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
        axi_arv_arr_flag : in std_logic;        
	    axi_awaddr, axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0)
	);
end myAXI_IP;

architecture arch_imp of myAXI_IP is
    component my_AXImem
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
            axi_arv_arr_flag : in std_logic;        
            axi_awaddr, axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0)
        );
    end component;

    component my_AXIfifo
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
    end component;

    component static_ip -- pixel processor
        generic ( NC: INTEGER:= 4; -- number of cores (NI-to-NO LUTs)
                  NI: INTEGER:= 9;
                  NO: INTEGER:= 9;
                  USE_PRIM: STRING:= "YES"); -- "YES": use the ROM(2**L)x1 primitive, "NO" uses simple VHDL statement
        port ( dyn_in:  in std_logic_vector(NC*NI - 1 downto 0);
               dyn_out: out std_logic_vector(NC*NO - 1 downto 0) );	
    end component;

begin

pa: if TYPO = "MEMO" generate
        -- up to 16 words can be stored in this memory
        -- TODO: add a parameter to this memory so that up to 256 words can be stored in this memory (simulate it!)
        th: my_AXImem generic map (C_S_AXI_DATA_WIDTH, C_S_AXI_ADDR_WIDTH)
            port map (S_AXI_ACLK, S_AXI_ARESETN, S_AXI_WVALID, S_AXI_WSTRB, S_AXI_WREADY, S_AXI_RREADY, S_AXI_RVALID, S_AXI_RRESP, S_AXI_WDATA, S_AXI_RDATA, 
                      axi_awv_awr_flag, axi_arv_arr_flag, axi_awaddr, axi_araddr);
    end generate;

pb: if TYPO = "PIXO" generate
	    signal S_AXI_WVALIDq, S_AXI_WREADYq, axi_awv_awr_flagq: std_logic;
	    signal S_AXI_WSTRBq: std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);  
	    signal axi_awaddrq: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	    signal S_AXI_WDATAq, PIX_DATA: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
     begin
            -- Input Register:
            process( S_AXI_ACLK, S_AXI_ARESETN)
            begin
               if S_AXI_ARESETN = '0' then
                    S_AXI_WVALIDq <= '0'; S_AXI_WREADYq <= '0'; axi_awv_awr_flagq <= '0';
                    S_AXI_WSTRBq <= (others => '0'); axi_awaddrq <= (others => '0'); S_AXI_WDATAq <= (others => '0');
               elsif ( rising_edge (S_AXI_ACLK) ) then
                    S_AXI_WVALIDq <= S_AXI_WVALID; S_AXI_WREADYq <= S_AXI_WREADY; axi_awv_awr_flagq <= axi_awv_awr_flag;
                    S_AXI_WSTRBq <= S_AXI_WSTRB; axi_awaddrq <= axi_awaddr; S_AXI_WDATAq <= S_AXI_WDATA;
               end if;           
            end process;
            
            -- pixel processor
            ji: static_ip generic map (NC => 4, NI => 8, NO => 8, USE_PRIM => "NO")
                port map (dyn_in => S_AXI_WDATAq, dyn_out => PIX_DATA);
            
            -- Memory:
            tv: my_AXImem generic map (C_S_AXI_DATA_WIDTH, C_S_AXI_ADDR_WIDTH)
                port map (S_AXI_ACLK, S_AXI_ARESETN, S_AXI_WVALIDq, S_AXI_WSTRBq, S_AXI_WREADYq, S_AXI_RREADY, S_AXI_RVALID, S_AXI_RRESP, PIX_DATA, S_AXI_RDATA, 
                          axi_awv_awr_flagq, axi_arv_arr_flag, axi_awaddrq, axi_araddr);
    end generate;
    
pc: if TYPO="FIFO" generate
        th: my_AXIfifo generic map (C_S_AXI_DATA_WIDTH, C_S_AXI_ADDR_WIDTH)
            port map (S_AXI_ACLK, S_AXI_ARESETN, S_AXI_WVALID, S_AXI_WSTRB, S_AXI_WREADY, S_AXI_RREADY, S_AXI_RVALID, S_AXI_RRESP, S_AXI_WDATA, S_AXI_RDATA, 
                      axi_awv_awr_flag, axi_arv_arr_flag);        
    end generate;
        
end arch_imp;

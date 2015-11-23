library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_AXImem is
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
end my_AXImem;

architecture arch_imp of my_AXImem is

    signal axi_rvalid : std_logic;
    signal axi_rresp  : std_logic_vector(1 downto 0);
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;

	------------------------------------------------
	---- Signals for user logic memory space example
	--------------------------------------------------
	signal mem_address : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	signal mem_data_out : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal mem_rden : std_logic;
    signal mem_wren : std_logic;
	signal mem_byte_index : integer;
	type BYTE_RAM_TYPE is array (0 to 15) of std_logic_vector(7 downto 0);
	
begin

	-- Implement axi_arvalid generation

	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
    S_AXI_RVALID <= axi_rvalid;
    S_AXI_RRESP	<= axi_rresp;
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arv_arr_flag = '1' and axi_rvalid = '0') then -- The axi_arv_arr_flag flag marks the presence of read address valid, i.e., we are ready to read
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        axi_rvalid <= '0';
	      end  if;      
	    end if;
	  end if;
	end process;	
	-- ------------------------------------------
	-- -- Example code to access user logic memory region
	-- ------------------------------------------
	-- This is an interesting code for BRAM usage (no need to use primitives!!!)
    -- Inputs: mem_address: Dependent on: axi_araddr, axi_awaddr
    --         mem_wren: Dependent on: axi_wready, S_AXI_WVALID
    --         mem_rden: Dependent on: axi_arv_arr_flag
    --         S_AXI_WDATA
    --         S_AXI_WSTRB
    --         S_AXI_RVALID
    -- Outputs: S_AXI_RDATA
    
	  mem_address <= axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) when axi_arv_arr_flag = '1' else
	                 axi_awaddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) when axi_awv_awr_flag = '1' else
	                 (others => '0');
 
	  mem_wren <= S_AXI_WREADY and S_AXI_WVALID ;
	  mem_rden <= axi_arv_arr_flag ;
	
	 -- We need this loop because the burst might not be of C_S_AXI_DATA_WIDTH (usually 32 bits). It might be just 16 or 8 bits.
	  -- In this loop, we go in units of 8 bits each.
	 -- In that case, the S_AXI_WSTRB signal will indicate which bytes are valid on each transfer
	 -- If mem_wren = '1' then, we can capture the input data (on S_AXI_WDATA) on 'byte_ram' (there are C_S_AXI_DATA_WDITH/8 of these signals)
	 -- If mem_rden = '1', then we output the corresponding group of 'byte_ram's if S_AXI_RVALID='1'
	 -- At every loop iteration, a new 'byte_ram' signal is generated. So, we can have 16 words (usually of 32 bits) stored in this memory.
	 BYTE_BRAM_GEN : for mem_byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) generate
	   signal byte_ram : BYTE_RAM_TYPE;
	   signal data_in  : std_logic_vector(8-1 downto 0);
	   signal data_out : std_logic_vector(8-1 downto 0);
	 begin
	   --assigning 8 bit data
	   data_in  <= S_AXI_WDATA((mem_byte_index*8+7) downto mem_byte_index*8);
	   data_out <= byte_ram(to_integer(unsigned(mem_address)));
	   BYTE_RAM_PROC : process( S_AXI_ACLK, S_AXI_ARESETN, mem_address ) is
	   begin
	     if S_AXI_ARESETN = '0' then
            byte_ram(to_integer(unsigned(mem_address))) <= (others =>'0');
	        mem_data_out((mem_byte_index*8+7) downto mem_byte_index*8) <= (others => '0');
	     elsif ( rising_edge (S_AXI_ACLK) ) then
	        if ( mem_wren = '1' and S_AXI_WSTRB(mem_byte_index) = '1' ) then
	           byte_ram(to_integer(unsigned(mem_address))) <= data_in;
	        end if;
	        if ( mem_rden = '1') then 
               mem_data_out((mem_byte_index*8+7) downto mem_byte_index*8) <= data_out;
            end if;	       
	     end if;
	   end process BYTE_RAM_PROC;
	 end generate BYTE_BRAM_GEN;

	--Output register or memory read data
	process(mem_data_out, axi_rvalid) is
	begin
	  if (axi_rvalid = '1') then
	    -- When there is a valid read address (S_AXI_ARVALID) with 
	    -- acceptance of read address by the slave (axi_arready), 
	    -- output the read data 
	    S_AXI_RDATA <= mem_data_out;  -- memory range 0 read data
	  else
	    S_AXI_RDATA <= (others => '0');
	  end if;  
	end process;

end arch_imp;

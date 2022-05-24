library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dual_moving_average is
    Generic(
		DATA_LENGTH		: Integer := 24;
		CLK_FREQUENCY 	: Integer := 100_000_000;
        n_samples 		: integer := 32
    );
    Port (
        aclk     		: in std_logic;
        aresetn     	: in std_logic;
        
        filter_enable	: in std_logic;
        
        s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in std_logic
    );
end dual_moving_average;

architecture Behavioral of dual_moving_average is

	-- COMPONENTS -- 
    component data_receiver is
		Generic(
			DATA_LENGTH	:	Integer:= 24
		);
        Port (
            aclk     		: in std_logic;
            aresetn     	: in std_logic;
            
            s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            s_axis_tvalid   : in std_logic;
            s_axis_tlast    : in std_logic;
            s_axis_tready   : out std_logic;
            
            data_left 		: out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            data_right 		: out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
        );
    end component;
    
    component mono_moving_average is
        Generic(
			DATA_LENGTH		: Integer := 24;
			CLK_FREQUENCY 	: Integer := 100_000_000;
            n_samples 		: integer := 32
        );
        Port (
            aclk     		: in std_logic;
            aresetn     	: in std_logic;
            
            filter_enable 	: in std_logic;
            
            din 			: in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            dout 			: out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
        );
    end component;
    
    component data_sender is
		Generic(
			DATA_LENGTH	:	Integer:= 24
		);
        Port (
            aclk     		: in std_logic;
            aresetn     	: in std_logic;
            
            data_right    	: in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            data_left    	: in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            
            m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tready   : in std_logic
        );
    end component;
    
	-- SIGNALS --
	-- internal signal for the right and left channels
    signal s_left_data 	: std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    signal s_right_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    
    signal m_left_data 	: std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    signal m_right_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    
begin
	-- INSTANCES --
	-- axi4-stream interface : slave part . The data received by the slave interface are sent to the moving average modules
    S_AXIS_PORT_INST : data_receiver
	Generic Map(
		DATA_LENGTH 	=> DATA_LENGTH
	)
    Port Map(
        aclk 		  	=> aclk,
        aresetn		  	=> aresetn,
        s_axis_tdata  	=> s_axis_tdata,
        s_axis_tvalid 	=> s_axis_tvalid,
        s_axis_tlast  	=> s_axis_tlast, 
        s_axis_tready 	=> s_axis_tready,
        data_left 		=> s_left_data,
        data_right		=> s_right_data
    );
    
	-- We use two different instances to separately calculate the filtering effect in the right and left channels.
	-- moving average module for the left channel 
    LEFT_AVERAGE : mono_moving_average
    Generic Map(
		DATA_LENGTH		=> DATA_LENGTH,
		CLK_FREQUENCY   => CLK_FREQUENCY,
        n_samples   	=> n_samples
    )
    Port Map(
        aclk 			=> aclk,
        aresetn 		=> aresetn,
        filter_enable 	=> filter_enable,
        din 			=> s_left_data,
        dout 			=> m_left_data
    );
    
	-- moving average module for the right channel 
    RIGHT_AVERAGE : mono_moving_average
    Generic Map(
		DATA_LENGTH		=> DATA_LENGTH,
		CLK_FREQUENCY   => CLK_FREQUENCY,
        n_samples 		=> n_samples
    )
    Port Map(
        aclk 			=> aclk,
        aresetn 		=> aresetn,
        filter_enable 	=> filter_enable,
        din 			=> s_right_data,
        dout 			=> m_right_data
    );
    
    -- axi4-stream interface : master part . The data coming from the moving average modules are sent through the master interface 
    M_AXIS_PORT_INST : data_sender
	Generic Map(
		DATA_LENGTH 	=> DATA_LENGTH
	)
    Port Map(
        aclk 			=> aclk,
        aresetn 		=> aresetn,
        m_axis_tdata 	=> m_axis_tdata,
        m_axis_tvalid 	=> m_axis_tvalid,
        m_axis_tlast	=> m_axis_tlast, 
        m_axis_tready 	=> m_axis_tready,
        data_left 		=> m_left_data,
        data_right 		=> m_right_data
    );
    
end Behavioral;
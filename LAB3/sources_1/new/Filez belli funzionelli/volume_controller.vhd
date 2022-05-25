library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity volume_controller is
    Generic(
		DATA_LENGTH	:	Integer:= 24;
		--This generic permits us to use this module for the general amplification and also for the Sx and Dx balancing
		BALANCE		:	Integer range 0 to 1:=0;
        -- We only need this generic to determine the width amp_power can reach, e.g. with units = 5 we can achieve..
        -- a max amplification of 2**16, so we'll need 1+log2(16)= 5 bits.
        jstk_units : integer range 5 to 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        volume : in std_logic_vector(9 DOWNTO 0);
        
        s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in std_logic
    );
end volume_controller;

architecture Behavioral of volume_controller is
	--This component will manage the AXI4Stream receive for us
    component data_receiver is
		Generic(
			DATA_LENGTH	:	Integer:= 24
		);
        Port (
            aclk     : in std_logic;
            aresetn     : in std_logic;
            
            s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            s_axis_tvalid   : in std_logic;
            s_axis_tlast    : in std_logic;
            s_axis_tready   : out std_logic;
            
            data_left : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            data_right : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
        );
    end component;
    --This component will read the joystick value and give us the sign and power of the amplification
    component amp_generator is
    Generic(
        jstk_units : integer range 5 TO 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        volume : in std_logic_vector(9 DOWNTO 0);
        
        amp_power : out std_logic_vector(9-jstk_units DOWNTO 0);
        amp_sign : out std_logic
    );
    end component;
	--This component will perform the amplification
	component mono_signal_amp is
		Generic(
			DATA_LENGTH	:	Integer:= 24;
			BALANCE		:	Integer range 0 to 1:=0;
			DXSX		:	std_logic:='0';
			jstk_units : integer range 5 to 9 := 6
		);
		Port (
			aclk     : in std_logic;
			aresetn     : in std_logic;
			
			din : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
			
			amp_power : in std_logic_vector(9-jstk_units DOWNTO 0);
			amp_sign : in std_logic;
			
			dout : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
		);
	end component;
    --This component will manage the AXI4Stream transmit for us
    component data_sender is
		Generic(
			DATA_LENGTH	:	Integer:= 24
		);
        Port (
            aclk     : in std_logic;
            aresetn     : in std_logic;
            
            data_right    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            data_left    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            
            m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tready   : in std_logic
        );
    end component;
    
    
    signal s_left_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    signal s_right_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    
    signal amp_power : std_logic_vector(9-jstk_units DOWNTO 0);
    signal amp_sign : std_logic;
    
    signal m_left_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    signal m_right_data : std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
    
begin

    S_AXIS_PORT_INST : data_receiver
	Generic map(
		DATA_LENGTH=>DATA_LENGTH
	)
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        s_axis_tdata => s_axis_tdata,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tlast => s_axis_tlast, 
        s_axis_tready => s_axis_tready,
        data_left => s_left_data,
        data_right => s_right_data
    );
    
    AMP_GEN_INST : amp_generator
    Generic Map(
        jstk_units => jstk_units
    )
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        volume => volume,
        amp_power => amp_power,
        amp_sign => amp_sign
    );
    --We instantiate the same module twice, one time for the left channel
    LEFT_AMP_INST : mono_signal_amp
    Generic Map(
		DATA_LENGTH=>DATA_LENGTH,
		BALANCE=>BALANCE,
		DXSX=>'1',
        jstk_units => jstk_units
    )
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        din => s_left_data,
        amp_power => amp_power,
        amp_sign => amp_sign,
        dout => m_left_data
    );
    --The second time for the right channel
    RIGHT_AMP_INST : mono_signal_amp
    Generic Map(
		DATA_LENGTH=>DATA_LENGTH,
		BALANCE=>BALANCE,
		DXSX=>'0',
        jstk_units => jstk_units
    )
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        din => s_right_data,
        amp_power => amp_power,
        amp_sign => amp_sign,
        dout => m_right_data
    );

    M_AXIS_PORT_INST : data_sender
	Generic map(
		DATA_LENGTH=>DATA_LENGTH
	)
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        m_axis_tdata => m_axis_tdata,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tlast => m_axis_tlast, 
        m_axis_tready => m_axis_tready,
        data_left => m_left_data,
        data_right => m_right_data
    );

end Behavioral;
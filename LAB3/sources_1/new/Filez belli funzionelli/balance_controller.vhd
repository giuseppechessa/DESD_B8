library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity balance_controller is
    Generic(
        jstk_units : integer range 5 to 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        balance : std_logic_vector(9 DOWNTO 0);
        
        s_axis_tdata    : in std_logic_vector(24-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        m_axis_tdata    : out std_logic_vector(24-1 DOWNTO 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in std_logic
    );
end balance_controller;

architecture Behavioral of balance_controller is

    component data_receiver is
        Port (
            aclk     : in std_logic;
            aresetn     : in std_logic;
            
            s_axis_tdata    : in std_logic_vector(24-1 DOWNTO 0);
            s_axis_tvalid   : in std_logic;
            s_axis_tlast    : in std_logic;
            s_axis_tready   : out std_logic;
            
            data_left : out std_logic_vector(24-1 DOWNTO 0);
            data_right : out std_logic_vector(24-1 DOWNTO 0)
        );
    end component;
    
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
    
    component mono_signal_amp is
        Generic(
            jstk_units : integer range 5 to 9 := 6
        );
        Port (
            aclk     : in std_logic;
            aresetn     : in std_logic;
            
            din : in std_logic_vector(24-1 DOWNTO 0);
            
            amp_power : in std_logic_vector(9-jstk_units DOWNTO 0);
            amp_sign : in std_logic;
            
            channel_check : in std_logic;
            balance_check : in std_logic;
            
            dout : out std_logic_vector(24-1 DOWNTO 0)
        );
    end component;
    
    component data_sender is
        Port (
            aclk     : in std_logic;
            aresetn     : in std_logic;
            
            data_right    : in std_logic_vector(24-1 DOWNTO 0);
            data_left    : in std_logic_vector(24-1 DOWNTO 0);
            
            m_axis_tdata    : out std_logic_vector(24-1 DOWNTO 0);
            m_axis_tvalid   : out std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tready   : in std_logic
        );
    end component;
    
    constant balance_check : std_logic := '1';
    constant left_channel : std_logic := '0';
    
    signal s_left_data : std_logic_vector(24-1 DOWNTO 0);
    signal s_right_data : std_logic_vector(24-1 DOWNTO 0);
    
    signal amp_power : std_logic_vector(9-jstk_units DOWNTO 0);
    signal amp_sign : std_logic;
    
    signal m_left_data : std_logic_vector(24-1 DOWNTO 0);
    signal m_right_data : std_logic_vector(24-1 DOWNTO 0);
    
begin

    S_AXIS_PORT_INST : data_receiver
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
        volume => balance,
        amp_power => amp_power,
        amp_sign => amp_sign
    );
    
    LEFT_AMP_INST : mono_signal_amp
    Generic Map(
        jstk_units => jstk_units
    )
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        din => s_left_data,
        amp_power => amp_power,
        amp_sign => amp_sign,
        channel_check => left_channel,
        balance_check => balance_check,
        dout => m_left_data
    );
    
    RIGHT_AMP_INST : mono_signal_amp
    Generic Map(
        jstk_units => jstk_units
    )
    Port Map(
        aclk => aclk,
        aresetn => aresetn,
        din => s_right_data,
        amp_power => amp_power,
        amp_sign => amp_sign,
        channel_check => not left_channel,
        balance_check => balance_check,
        dout => m_right_data
    );
    
    M_AXIS_PORT_INST : data_sender
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
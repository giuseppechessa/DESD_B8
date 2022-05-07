library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity jstk_uart_bridge is
	generic (
		HEADER_CODE		: std_logic_vector(7 downto 0) := "11000000"; -- Header of the packet
		TX_DELAY		: positive := 1000000;    -- Pause (in clock cycles) between two packets
		JSTK_BITS		: integer range 1 to 7 := 7    -- Number of bits of the joystick axis to transfer to the PC 
	);
	Port ( 
		aclk 			: in  STD_LOGIC;
		aresetn			: in  STD_LOGIC;

		-- Data going TO the PC (i.e., joystick position and buttons state)
		m_axis_tvalid	: out STD_LOGIC;
		m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axis_tready	: in STD_LOGIC;

		-- Data coming FROM the PC (i.e., LED color)
		s_axis_tvalid	: in STD_LOGIC;
		s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);
		s_axis_tready	: out STD_LOGIC;
		
        jstk_x			: in std_logic_vector(9 downto 0);
        jstk_y			: in std_logic_vector(9 downto 0);
		btn_jstk		: in std_logic;
		btn_trigger		: in std_logic;

		led_r			: out std_logic_vector(7 downto 0);
		led_g			: out std_logic_vector(7 downto 0);
		led_b			: out std_logic_vector(7 downto 0)
	);
end jstk_uart_bridge;

architecture Behavioral of jstk_uart_bridge is
	
	component Buttons_Packer is
        generic (
            HEADER_CODE		: std_logic_vector(7 downto 0);
            TX_DELAY		: positive := 1000000;
            JSTK_BITS		: integer range 1 to 7 := 7
        );
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;

            jstk_x			: in std_logic_vector(9 downto 0);
            jstk_y			: in std_logic_vector(9 downto 0);
            btn_jstk		: in std_logic;
            btn_trigger		: in std_logic;

            m_axis_tready	: in STD_LOGIC;
            m_axis_tvalid	: out STD_LOGIC;
            m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component LED_Unpacker is
        generic (
            HEADER_CODE		: std_logic_vector(7 downto 0) := "11000000" -- Header of the packet
        );
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;
    
            -- Data coming FROM the PC (i.e., LED color)
            s_axis_tvalid	: in STD_LOGIC;
            s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);
            s_axis_tready	: out STD_LOGIC;
    
            led_r			: out std_logic_vector(7 downto 0);
            led_g			: out std_logic_vector(7 downto 0);
            led_b			: out std_logic_vector(7 downto 0)
        );
    end component;

begin

    BUTTONS_PACKER_INST : Buttons_Packer
    Generic Map(
        HEADER_CODE => HEADER_CODE,
        TX_DELAY => TX_DELAY,
        JSTK_BITS => JSTK_BITS
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        jstk_x => jstk_x,
        jstk_y => jstk_y,
        btn_jstk => btn_jstk,
        btn_trigger => btn_trigger,
        m_axis_tready => m_axis_tready,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tdata => m_axis_tdata
    );
    
    LED_UNPACKER_INST : LED_Unpacker
    Generic Map(
        HEADER_CODE => HEADER_CODE
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tdata => s_axis_tdata,
        s_axis_tready => s_axis_tready,
        led_r => led_r,
        led_g => led_g,
        led_b => led_b
    );

end architecture;
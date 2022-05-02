library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digilent_jstk2 is
	generic (
		DELAY_US		: integer := 25;    -- Delay (in us) between two packets
		CLKFREQ		 	: integer := 100000000;  -- Frequency of the aclk signal (in Hz)
		SPI_SCLKFREQ 	: integer := 5000 -- Frequency of the SPI SCLK clock signal (in Hz)
	);
	Port ( 
		aclk 			: in  STD_LOGIC;
		aresetn			: in  STD_LOGIC;

		-- Data going TO the SPI IP-Core (and so, to the JSTK2 module)
		m_axis_tvalid	: out STD_LOGIC;
		m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axis_tready	: in STD_LOGIC;

		-- Data coming FROM the SPI IP-Core (and so, from the JSTK2 module)
		-- There is no tready signal, so you must be always ready to accept and use the incoming data, or it will be lost!
		s_axis_tvalid	: in STD_LOGIC;
		s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);

		-- Joystick and button values read from the module
		jstk_x			: out std_logic_vector(9 downto 0);
		jstk_y			: out std_logic_vector(9 downto 0);
--		jstk_x			: out std_logic_vector(11 downto 0);
--		jstk_y			: out std_logic_vector(11 downto 0);
		btn_jstk		: out std_logic;
		btn_trigger		: out std_logic;

		-- LED color to send to the module
		led_r			: in std_logic_vector(7 downto 0);
		led_g			: in std_logic_vector(7 downto 0);
		led_b			: in std_logic_vector(7 downto 0)
	);
end digilent_jstk2;

architecture Behavioral of digilent_jstk2 is

	-- Code for the SetLEDRGB command (84 in HEX), see the JSTK2 datasheet.
	constant cmdSetLEDRGB		: std_logic_vector(7 downto 0) := x"84";

	-- Inter-packet delay plus the time needed to transfer 1 byte (for the CS de-assertion)
	constant DELAY_CYCLES		: integer := DELAY_US * (CLKFREQ / 1000000) + CLKFREQ / SPI_SCLKFREQ;
	
	component LED_Packer is
        generic (
            DELAY_CYCLES    : integer;
            HEADER          : std_logic_vector(7 downto 0)
        );
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;

            m_axis_tvalid	: out STD_LOGIC;
            m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0);
            m_axis_tready	: in STD_LOGIC;

            led_r			: in std_logic_vector(7 downto 0);
            led_g			: in std_logic_vector(7 downto 0);
            led_b			: in std_logic_vector(7 downto 0)
        );
    end component;
    
    component Buttons_Unpacker is
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;
            
            s_axis_tvalid	: in STD_LOGIC;
            s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);

            jstk_x			: out std_logic_vector(9 downto 0);
            jstk_y			: out std_logic_vector(9 downto 0);
--            jstk_x			: out std_logic_vector(11 downto 0);
--            jstk_y			: out std_logic_vector(11 downto 0);
            btn_jstk		: out std_logic;
            btn_trigger		: out std_logic
        );
    end component;

begin

    LED_PACKER_INST : LED_Packer
    Generic Map(
        DELAY_CYCLES => DELAY_CYCLES,
        HEADER => cmdSetLEDRGB
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tdata => m_axis_tdata,
        m_axis_tready => m_axis_tready,
        led_r => led_r,	
        led_g => led_g,
        led_b => led_b
    );
    
    BUTTONS_UNPACKER_INST : Buttons_Unpacker
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tdata => s_axis_tdata,
        jstk_x => jstk_x,	
        jstk_y => jstk_y,
        btn_jstk => btn_jstk,
        btn_trigger => btn_trigger
    );
    
end architecture;
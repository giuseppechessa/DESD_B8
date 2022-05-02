library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_LED_Packer is
--  Port ( );
end TB_LED_Packer;

architecture Behavioral of TB_LED_Packer is
    
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
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	constant DELAY_US		: integer := 25;    -- Delay (in us) between two packets
    constant CLKFREQ		: integer := 100_000_000;  -- Frequency of the aclk signal (in Hz)
	constant SPI_SCLKFREQ 	: integer := 66_666; -- Frequency of the SPI SCLK clock signal (in Hz)
	constant DELAY_CYCLES	: integer := DELAY_US * (CLKFREQ / 1_000_000) + CLKFREQ / SPI_SCLKFREQ;
	
	constant cmdSetLEDRGB		: std_logic_vector(7 downto 0) := x"84";
	
    signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
	
	signal m_axis_tvalid	: STD_LOGIC;
    signal m_axis_tdata	    : STD_LOGIC_VECTOR(7 downto 0);
    signal m_axis_tready	: STD_LOGIC;
    
    signal led_r	: std_logic_vector(7 downto 0);
    signal led_g	: std_logic_vector(7 downto 0);
    signal led_b	: std_logic_vector(7 downto 0);
    
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
    
    aclk	<=	not aclk after CLK_PERIOD/2;
	
	-- Reset Process 
	reset_wave :process
	begin
		aresetn <= '0';
		wait for RESET_WND;
		
		aresetn <= '1';
		wait;
    end process;
    
    process
    begin
        
        led_r <= "01011010";
        led_g <= "10011001";
        led_b <= "00011000";
        wait for RESET_WND;
        wait for CLK_PERIOD*10;
        m_axis_tready <= '1';
        wait for 10ms;
        m_axis_tready <= '0';
        wait;
        
    end process;
    
end Behavioral;

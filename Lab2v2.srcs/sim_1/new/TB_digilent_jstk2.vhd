library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_digilent_jstk2 is
--  Port ( );
end TB_digilent_jstk2;

architecture Behavioral of TB_digilent_jstk2 is
    
    component digilent_jstk2 is
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
    end component;
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	constant DELAY_US		: integer := 25;    -- Delay (in us) between two packets
    constant CLKFREQ		: integer := 100000000;  -- Frequency of the aclk signal (in Hz)
    constant SPI_SCLKFREQ 	: integer := 5000; -- Frequency of the SPI SCLK clock signal (in Hz)
    
    signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
	
	signal s_axis_tvalid	: STD_LOGIC;
    signal s_axis_tdata	: STD_LOGIC_VECTOR(7 downto 0);
    
    signal m_axis_tvalid	: STD_LOGIC;
    signal m_axis_tdata	    : STD_LOGIC_VECTOR(7 downto 0);
    signal m_axis_tready	: STD_LOGIC;
    
    signal jstk_x			: std_logic_vector(9 downto 0);
    signal jstk_y			: std_logic_vector(9 downto 0);
    signal btn_jstk		    :	std_logic;
    signal btn_trigger		:	std_logic;
    
    signal led_r	: std_logic_vector(7 downto 0);
    signal led_g	: std_logic_vector(7 downto 0);
    signal led_b	: std_logic_vector(7 downto 0);
    
begin

    JSTK2_INST : digilent_jstk2
    Generic Map(
        DELAY_US => DELAY_US,
        CLKFREQ => CLKFREQ,
        SPI_SCLKFREQ => SPI_SCLKFREQ
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tdata => m_axis_tdata,
        m_axis_tready => m_axis_tready,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tdata => s_axis_tdata,
        jstk_x => jstk_x,	
        jstk_y => jstk_y,
        btn_jstk => btn_jstk,
        btn_trigger => btn_trigger,
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
        
        wait for RESET_WND;
        m_axis_tready <= '1';
        
        wait for CLK_PERIOD*50;
        
        s_axis_tvalid <= '1';
        s_axis_tdata <= "10011001";
        wait for CLK_PERIOD;
        s_axis_tdata <= "01111110";
        wait for CLK_PERIOD;
        s_axis_tdata <= "10101000";    
        wait for CLK_PERIOD;
        s_axis_tdata <= "10001010";
        wait for CLK_PERIOD;
        s_axis_tdata <= "00101011";
        wait for CLK_PERIOD;
        
        s_axis_tdata <= "01101100";
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD*20;
        s_axis_tvalid <= '1';
        
        wait for 125us;
        led_r <= "10101010";
        led_g <= "01010101";
        led_b <= "00110011";
        wait for 125us;
        wait;
    end process;
end Behavioral;

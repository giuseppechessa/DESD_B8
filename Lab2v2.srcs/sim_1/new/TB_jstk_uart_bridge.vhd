library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_jstk_uart_bridge is
--  Port ( );
end TB_jstk_uart_bridge;

architecture Behavioral of TB_jstk_uart_bridge is

    component jstk_uart_bridge is
        generic (
            HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0"; -- Header of the packet
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
    end component;
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	constant HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0";
	constant TX_DELAY		: positive := 1000000;    -- Pause (in clock cycles) between two packets
	constant JSTK_BITS		: integer range 1 to 7 := 7;
	
	signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
	
	signal s_axis_tvalid	: STD_LOGIC;
    signal s_axis_tdata	: STD_LOGIC_VECTOR(7 downto 0);
    signal s_axis_tready	: STD_LOGIC;
    
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

    JSTK_UART_BRIDGE_INST: jstk_uart_bridge
    Generic Map(
        HEADER_CODE => HEADER_CODE,
        TX_DELAY => TX_DELAY,
        JSTK_BITS => JSTK_BITS
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        m_axis_tready => m_axis_tready,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tdata => m_axis_tdata,
        s_axis_tvalid => s_axis_tvalid,
        s_axis_tdata => s_axis_tdata,
        s_axis_tready => s_axis_tready,
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
        
        wait for 1000ns;
        s_axis_tvalid <= '1';
        s_axis_tdata <= HEADER_CODE;
        wait for CLK_PERIOD;
        s_axis_tdata <= "10000001";
        wait for CLK_PERIOD;
        s_axis_tdata <= "01111110";
        wait for CLK_PERIOD;
        s_axis_tdata <= "10101010";
        wait for CLK_PERIOD*20;
        s_axis_tvalid <= '0';
        s_axis_tdata <= HEADER_CODE;
        wait for CLK_PERIOD*20;
        s_axis_tvalid <= '1';
        wait for CLK_PERIOD;
        s_axis_tdata <= "10111001";
        wait for CLK_PERIOD;
        s_axis_tdata <= "00001110";
        wait for CLK_PERIOD;
        s_axis_tdata <= "10101000";
        wait for CLK_PERIOD;
        s_axis_tdata <= HEADER_CODE;
        wait for CLK_PERIOD*3;
        s_axis_tdata <= "01111110";
        wait for CLK_PERIOD;
        s_axis_tdata <= "10101010";
        
        wait for CLK_PERIOD*10;
        s_axis_tdata <= HEADER_CODE;
        
        m_axis_tready <= '1';
        jstk_x <= "1010101010";
        jstk_y <= "0101010101";
        btn_jstk <= '0';
        btn_trigger <= '1';
        wait for 15ms;
        
        m_axis_tready <= '0';
        
        jstk_x <= "0101010101";
        jstk_y <= "1010101010";
        btn_jstk <= '1';
        btn_trigger <= '0';
        wait for 10ms;
        m_axis_tready <= '1';
        
        wait;
        
    end process;
    
end Behavioral;

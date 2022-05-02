library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_LED_Unpacker is
--  Port ( );
end TB_LED_Unpacker;

architecture Behavioral of TB_LED_Unpacker is
    
    component LED_Unpacker is
        generic (
            HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0" -- Header of the packet
        );
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;
    
            s_axis_tvalid	: in STD_LOGIC;
            s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);
            s_axis_tready	: out STD_LOGIC;
    
            led_r			: out std_logic_vector(7 downto 0);
            led_g			: out std_logic_vector(7 downto 0);
            led_b			: out std_logic_vector(7 downto 0)
        );
    end component;
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	constant HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0";
	
    signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
	
	signal s_axis_tvalid	: STD_LOGIC;
    signal s_axis_tdata	: STD_LOGIC_VECTOR(7 downto 0);
    signal s_axis_tready	: STD_LOGIC;
    
    signal led_r	: std_logic_vector(7 downto 0);
    signal led_g	: std_logic_vector(7 downto 0);
    signal led_b	: std_logic_vector(7 downto 0);
	
begin

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
        
        wait;
    end process;

end Behavioral;

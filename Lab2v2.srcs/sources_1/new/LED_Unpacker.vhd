library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_Unpacker is
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
end LED_Unpacker;

architecture Behavioral of LED_Unpacker is

	type rx_state_type is (IDLE, GET_HEADER, GET_LED_R, GET_LED_G, GET_LED_B);
	signal rx_state			: rx_state_type := GET_HEADER;
	
	signal s_axis_tready_sig : std_logic := '0';
	
begin
    
    s_axis_tready <= s_axis_tready_sig;
    
    with rx_state select s_axis_tready_sig <=
        '0' when IDLE,
        '1' when GET_HEADER,
        '1' when GET_LED_R,
        '1' when GET_LED_G,
        '1' when GET_LED_B,
        '0' when Others;
        
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                rx_state <= IDLE;
                led_r <= (Others => '0');
                led_g <= (Others => '0');
                led_b <= (Others => '0');
                
            else
                
                case rx_state is
                
                    when IDLE =>
                        rx_state <= GET_HEADER;
                        
                    when GET_HEADER =>
                        if s_axis_tvalid = '1' and s_axis_tdata = HEADER_CODE then
                            rx_state <= GET_LED_R;
                        end if;
                    
                    when GET_LED_R =>
                        if s_axis_tvalid = '1' then
                            led_r <= s_axis_tdata;
                            rx_state <= GET_LED_G;
                        end if;
                        
                    when GET_LED_G =>
                        if s_axis_tvalid = '1' then
                            led_g <= s_axis_tdata;
                            rx_state <= GET_LED_B;
                        end if;
                    
                    when GET_LED_B =>
                        if s_axis_tvalid = '1' then
                            led_b <= s_axis_tdata;
                            rx_state <= IDLE;
                        end if;
                        
                end case;
            
            end if;
            
        end if;
        
    end process;        

end Behavioral;
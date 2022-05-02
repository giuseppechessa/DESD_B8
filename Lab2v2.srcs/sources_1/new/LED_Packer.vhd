library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_Packer is
	generic (
		DELAY_CYCLES    : integer;
		HEADER          : std_logic_vector(7 downto 0)
	);
	Port ( 
		aclk 			: in  STD_LOGIC;
		aresetn			: in  STD_LOGIC;

		-- Data going TO the SPI IP-Core (and so, to the JSTK2 module)
		m_axis_tvalid	: out STD_LOGIC;
		m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0);
		m_axis_tready	: in STD_LOGIC;

		-- LED color to send to the module
		led_r			: in std_logic_vector(7 downto 0);
		led_g			: in std_logic_vector(7 downto 0);
		led_b			: in std_logic_vector(7 downto 0)
	);
end LED_Packer;

architecture Behavioral of LED_Packer is
    
    signal m_axis_tvalid_sig : std_logic := '0';
    
    type state_cmd_type is (WAIT_DELAY, SEND_CMD, SEND_RED, SEND_GREEN, SEND_BLUE, SEND_DUMMY);
	signal state_cmd			: state_cmd_type := WAIT_DELAY;
    
    signal n_clk_count : natural := 0;
    
begin

    m_axis_tvalid <= m_axis_tvalid_sig;
    
    with state_cmd select m_axis_tvalid_sig <=
        '0' when WAIT_DELAY,
        '1' when SEND_CMD,
        '1' when SEND_RED,
        '1' when SEND_GREEN,
        '1' when SEND_BLUE,
        '1' when SEND_DUMMY,
        '0' when Others;
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                n_clk_count <= 0;
                state_cmd <= WAIT_DELAY;
                
            else
            
                case state_cmd is
                        
                    when WAIT_DELAY =>
                        n_clk_count <= n_clk_count + 1;
                        if n_clk_count >= DELAY_CYCLES then
                            m_axis_tdata <= HEADER;
                            state_cmd <= SEND_CMD;
                        end if;
                        
                    when SEND_CMD =>
                        if m_axis_tready = '1' then
                            m_axis_tdata <= led_r;
                            state_cmd <= SEND_RED;
                        end if;
                         
                    when SEND_RED =>
                        if m_axis_tready = '1' then
                            m_axis_tdata <= led_g;
                            state_cmd <= SEND_GREEN;
                        end if;
                    
                    when SEND_GREEN =>
                        if m_axis_tready = '1' then
                            m_axis_tdata <= led_b;
                            state_cmd <= SEND_BLUE;
                        end if;
                    
                    when SEND_BLUE =>
                        if m_axis_tready = '1' then
                            m_axis_tdata <= HEADER;
                            state_cmd <= SEND_DUMMY;
                        end if;
                            
                    when SEND_DUMMY =>
                        if m_axis_tready = '1' then
                            n_clk_count <= 0;
                            state_cmd <= WAIT_DELAY;
                        end if;
                       
                    when Others =>
                        state_cmd <= WAIT_DELAY;
                        n_clk_count <= 0;
                    
                end case;

            end if;
            
        end if;
            
    end process;

end Behavioral;
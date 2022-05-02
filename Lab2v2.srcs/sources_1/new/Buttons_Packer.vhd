library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Buttons_Packer is
	generic (
		HEADER_CODE		: std_logic_vector(7 downto 0); -- Header of the packet
		TX_DELAY		: positive := 10000000;    -- Pause (in clock cycles) between two packets
		JSTK_BITS		: integer range 1 to 7 := 7    -- Number of bits of the joystick axis to transfer to the PC 
	);
	Port ( 
		aclk 			: in  STD_LOGIC;
		aresetn			: in  STD_LOGIC;

		jstk_x			: in std_logic_vector(9 downto 0);
		jstk_y			: in std_logic_vector(9 downto 0);
--		jstk_x			: in std_logic_vector(11 downto 0);
--		jstk_y			: in std_logic_vector(11 downto 0);
		btn_jstk		: in std_logic;
		btn_trigger		: in std_logic;
		
		-- Data going TO the PC (i.e., joystick position and buttons state)
		m_axis_tready	: in STD_LOGIC;
		m_axis_tvalid	: out STD_LOGIC;
		m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0)
	);
end Buttons_Packer;

architecture Behavioral of Buttons_Packer is

	type tx_state_type is (WAIT_DELAY, SEND_HEADER, SEND_JSTK_X, SEND_JSTK_Y, SEND_BUTTONS);
	signal tx_state			: tx_state_type := WAIT_DELAY;
    
    signal m_axis_tvalid_sig : std_logic := '1';
    
    signal n_clk_count : natural := 0;
    
begin

    m_axis_tvalid <= m_axis_tvalid_sig;
    
    with tx_state select m_axis_tvalid_sig <=
        '0' when WAIT_DELAY,
        '1' when SEND_HEADER,
        '1' when SEND_JSTK_X,
        '1' when SEND_JSTK_Y,
        '1' when SEND_BUTTONS,
        '0' when Others;
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                n_clk_count <= 0;
                tx_state <= WAIT_DELAY;
                
            else
            
                case tx_state is
                        
                    when WAIT_DELAY =>
                        n_clk_count <= n_clk_count + 1;
                        if n_clk_count >= TX_DELAY then
                            m_axis_tdata <= HEADER_CODE;
                            tx_state <= SEND_HEADER;
                        end if;
                        
                    when SEND_HEADER =>
                        if m_axis_tready = '1' then
--                            m_axis_tdata <= jstk_x(11 DOWNTO 11-JSTK_BITS);
                            m_axis_tdata <= jstk_x(9 DOWNTO 9-JSTK_BITS);
                            tx_state <= SEND_JSTK_X;
                        end if;
                        
                    when SEND_JSTK_X =>
                        if m_axis_tready = '1' then
--                            m_axis_tdata <= jstk_y(11 DOWNTO 11-JSTK_BITS);
                            m_axis_tdata <= jstk_y(9 DOWNTO 9-JSTK_BITS);
                            tx_state <= SEND_JSTK_Y;
                        end if;
                    
                    when SEND_JSTK_Y =>
                        if m_axis_tready = '1' then
                            m_axis_tdata <= (7 DOWNTO 2 => '0', 1 => btn_trigger, 0 => btn_jstk);
                            tx_state <= SEND_BUTTONS;
                        end if;
                    
                    when SEND_BUTTONS =>
                        if m_axis_tready = '1' then
                            n_clk_count <= 0;
                            tx_state <= WAIT_DELAY;
                        end if;
                        
                    when Others =>
                        n_clk_count <= 0;
                        tx_state <= WAIT_DELAY;
                        
                end case;

            end if;
            
        end if;
            
    end process;

end Behavioral;
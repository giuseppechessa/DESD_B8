library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_sender is
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
end data_sender;

architecture Behavioral of data_sender is

    type m_state_type is (IDLE, LEFT_CH, RIGHT_CH);
    signal m_state : m_state_type := IDLE;
    
    signal m_axis_tvalid_sig : std_logic := '0';
    
begin

    m_axis_tvalid <= m_axis_tvalid_sig;
    
    with m_state select m_axis_tvalid_sig <=
        '0' when IDLE,
        '1' when LEFT_CH,
        '1' when RIGHT_CH,
        '0' when Others;
        
    MASTER_FSM: process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
        
            if aresetn = '0' then
                m_state <= IDLE;
            
            else
                
                case m_state is
                    
                    when IDLE =>
                        m_axis_tlast <= '0';
                        m_state <= LEFT_CH;
                        
                    when LEFT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            m_axis_tdata <= data_left;
                            m_axis_tlast <= '0';
                            m_state <= RIGHT_CH;
                        end if;
                        
                    when RIGHT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            m_axis_tdata <= data_right;
                            m_axis_tlast <= '1';
                            m_state <= IDLE;
                        end if;
                        
                    when Others =>
                        m_state <= IDLE;
                        
                end case;

            end if;
            
        end if;
        
    end process;
    
end Behavioral;
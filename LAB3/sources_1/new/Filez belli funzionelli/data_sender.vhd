library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_sender is
	Generic(
		DATA_LENGTH	    :	Integer:= 24
	);
    Port (
        aclk            : in std_logic;
        aresetn         : in std_logic;
        
        -- These two signals contain the data that has been processed in this module.
        data_right      : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        data_left       : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        
        m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
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

    -- We need to have an IDLE state so that during resets we won't be able to receive any new data (s_axis_tready = '0')
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
                    
                    -- This state is not needed other than for resets, which means that after that we can just switch between LEFT_CH and RIGHT_CH.
                    when IDLE =>
                        m_axis_tlast <= '0';
                        m_state <= LEFT_CH;
                    
                    -- We send data from the left channel as long as the next Slave port is able to receive it, and we confirm it's coming from the..
                    -- .. left channel by having tlast = '0' while sending this data batch and setting it to '1' as soon as we switch to RIGHT_CH.
                    when LEFT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            m_axis_tdata <= data_left;
                            m_axis_tlast <= '1';
                            m_state <= RIGHT_CH;
                        end if;
                    
                    -- Likewise, we'll be sending data from the right channel with tlast = '1', setting it to '0' once we switch back to LEFT_CH.
                    when RIGHT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            m_axis_tdata <= data_right;
                            m_axis_tlast <= '0';
                            m_state <= LEFT_CH;
                        end if;
                        
                    when Others =>
                        m_state <= IDLE;
                        
                end case;

            end if;
            
        end if;
        
    end process;
    
end Behavioral;
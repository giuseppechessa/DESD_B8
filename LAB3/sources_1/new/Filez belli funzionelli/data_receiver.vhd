library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_receiver is
	Generic(
		DATA_LENGTH	:	Integer:= 24
	);
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        data_left : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        data_right : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
    );
end data_receiver;

architecture Behavioral of data_receiver is
    
    type s_state_type is (IDLE, LEFT_CH, RIGHT_CH);
    signal s_state : s_state_type := IDLE;
    
    signal s_axis_tready_sig : std_logic := '0';

begin

    s_axis_tready <= s_axis_tready_sig;
    
    with s_state select s_axis_tready_sig <=
        '0' when IDLE,
        '1' when LEFT_CH,
        '1' when RIGHT_CH,
        '0' when Others;
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
        
            if aresetn = '0' then
                s_state <= IDLE;
            
            else
                
                case s_state is
                    
                    when IDLE =>
                        s_state <= LEFT_CH;
                        
                    when LEFT_CH =>
                        if s_axis_tvalid = '1' and s_axis_tready_sig = '1' and s_axis_tlast = '0' then
                            data_left <= s_axis_tdata;
                            s_state <= RIGHT_CH;
                        end if;
                        
                    when RIGHT_CH =>
                        if s_axis_tvalid = '1' and s_axis_tready_sig = '1' and s_axis_tlast = '1' then
                            data_right <= s_axis_tdata;
                            s_state <= IDLE;
                        end if;
                        
                    when Others =>
                        s_state <= IDLE;
                        
                end case;

            end if;
            
        end if;
        
    end process;

end Behavioral;
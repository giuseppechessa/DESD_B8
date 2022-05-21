library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity moving_average is
	Generic(
        n_samples : integer := 32
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
		filter_enable : in std_logic;
		
        s_axis_tdata    : in std_logic_vector(24-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        m_axis_tdata    : out std_logic_vector(24-1 DOWNTO 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in std_logic
    );
end moving_average;

architecture Behavioral of moving_average is
    
    type state_type is (IDLE, LEFT_CH, RIGHT_CH);
    signal s_state : state_type := IDLE;
    signal m_state : state_type := IDLE;
	
    signal s_axis_tready_sig : std_logic := '0';
	signal m_axis_tvalid_sig : std_logic := '0';
	
	signal filter_check : std_logic := '0';
    
    constant extra_bits : integer := integer(log2(real(n_samples)));
    
    type filter_type is array(n_samples-1 DOWNTO 0) of signed(23 DOWNTO 0);
    signal filter_mem_left  : filter_type := (Others => (Others => '0'));
    signal filter_mem_right : filter_type := (Others => (Others => '0'));
	
    signal sum_right : signed(23 + extra_bits + 1 DOWNTO 0) := (Others => '0');
    signal sum_left  : signed(23 + extra_bits + 1 DOWNTO 0) := (Others => '0');
	

begin

    s_axis_tready <= s_axis_tready_sig;
	m_axis_tvalid <= m_axis_tvalid_sig;
    
    with s_state select s_axis_tready_sig <=
        '0' when IDLE,
        '1' when LEFT_CH,
        '1' when RIGHT_CH,
        '0' when Others;
		
	with m_state select m_axis_tvalid_sig <=
        '0' when IDLE,
        '1' when LEFT_CH,
        '1' when RIGHT_CH,
        '0' when Others;	
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
        
            if aresetn = '0' then
                s_state <= IDLE;
				
		        filter_mem_right <= (Others => (Others => '0'));
				filter_mem_left <= (Others => (Others => '0'));
                sum_right <= (Others => '0');
				sum_left <= (Others => '0');
				
            else
                			
                case s_state is
                    
                    when IDLE =>
                        s_state <= LEFT_CH;
                        
                    when LEFT_CH =>
                        if s_axis_tvalid = '1' and s_axis_tready_sig = '1' and s_axis_tlast = '0' then
						
							-- We add the new value to the current total sum while at the same time we get rid of the oldest value
							sum_left <= sum_left - signed(filter_mem_left(filter_mem_left'HIGH)) + signed(s_axis_tdata);
							-- We perform the replacement in the memory as well
							filter_mem_left <= filter_mem_left(filter_mem_left'HIGH-1 DOWNTO 0) & signed(s_axis_tdata); 
							
                            s_state <= RIGHT_CH;
                        end if;
						
                        
                    when RIGHT_CH =>
                        if s_axis_tvalid = '1' and s_axis_tready_sig = '1' and s_axis_tlast = '1' then
						
							-- We add the new value to the current total sum while at the same time we get rid of the oldest value
							sum_right <= sum_right - signed(filter_mem_right(filter_mem_right'HIGH)) + signed(s_axis_tdata);
							-- We perform the replacement in the memory as well
							filter_mem_right <= filter_mem_right(filter_mem_right'HIGH-1 DOWNTO 0) & signed(s_axis_tdata);
                            
                            s_state <= IDLE;
                        end if;
                        
                    when Others =>
                        s_state <= IDLE;
                        
                end case;
            end if;          
        end if;       
    end process;
	
	
	MASTER_FSM: process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
        
            if aresetn = '0' then
				filter_check <= '0' ;
                m_state <= IDLE;
            
            else
			
				if filter_enable = '1' then
                    filter_check <= not filter_check;
                end if;
                
                case m_state is
                    
                    when IDLE =>
                        m_axis_tlast <= '0';
                        m_state <= LEFT_CH;
                        
                    when LEFT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            if filter_check = '1' then
								-- The output is made by the sum of the n_samples current values in the memory, shifted rightwards by extra_bits
								m_axis_tdata <= std_logic_vector(sum_left(sum_left'HIGH-1 DOWNTO extra_bits)); 
							else
								-- If we're not enabling the computation, we may send the inout data to the output as it is.
								m_axis_tdata <= s_axis_tdata;
							end if;
							
                            m_axis_tlast <= '0';
                            m_state <= RIGHT_CH;
                        end if;
                        
                    when RIGHT_CH =>
                        if m_axis_tvalid_sig = '1' and m_axis_tready = '1' then
                            if filter_check = '1' then
								-- The output is made by the sum of the n_samples current values in the memory, shifted rightwards by extra_bits
								m_axis_tdata <= std_logic_vector(sum_right(sum_right'HIGH-1 DOWNTO extra_bits)); 
							else
								-- If we're not enabling the computation, we may send the inout data to the output as it is.
								m_axis_tdata <= s_axis_tdata;
							end if;
							
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
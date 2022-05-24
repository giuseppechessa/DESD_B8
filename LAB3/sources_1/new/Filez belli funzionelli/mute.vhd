library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mute is
	Generic(
		DATA_LENGTH	:	Integer:= 24
    );
	Port (
	  
			aclk : in std_logic ;
			aresetn : in std_logic ;
			
			mute_enable     : in std_logic;
			
			s_axis_tdata    : in std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
			s_axis_tvalid   : in std_logic;
			s_axis_tlast    : in std_logic;
			s_axis_tready   : out std_logic;
			
			m_axis_tdata    : out std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
			m_axis_tvalid   : out std_logic;
			m_axis_tlast    : out std_logic;
			m_axis_tready   : in std_logic
	  );
	end mute;

architecture Behavioral of mute is
    
    -- This signal changes value whenever we press the trigger button on the joystick.
    signal mute_check : std_logic := '0';
    
begin

    process(aclk,aresetn)
    begin
    
        if aresetn = '0' then 
            mute_check <= '0' ;
            
        elsif rising_edge(aclk) then

            -- We noticed that this module worked well without the AXI4-Stream Interfaces, just by sending the control signals to..
            -- .. the previous module or the following one.
            m_axis_tvalid <= s_axis_tvalid;
            m_axis_tlast <= s_axis_tlast;
            s_axis_tready <= m_axis_tready;

            -- We can't use mute_enable right away, as we'd have a level-triggered mute instead of an edge-triggered one.        
            if mute_enable = '1' then
                mute_check <= not mute_check;
            end if;

            -- If the mute_check is '0' we can just send the data as it arrived, otherwise we'll send zeros continuously.
            if mute_check = '0' then
                m_axis_tdata <= s_axis_tdata;
            elsif mute_check = '1' then
                m_axis_tdata <= (Others => '0');
            end if;

        end if ;
        
    end process;
    
end Behavioral;
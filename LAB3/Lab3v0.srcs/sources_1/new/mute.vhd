library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mute is
  Port (
        mute_enable     : in std_logic;
        
        s_axis_tdata    : in std_logic_vector(24-1 DOWNTO 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tready   : out std_logic;
        
        m_axis_tdata    : out std_logic_vector(24-1 DOWNTO 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tready   : in std_logic
  );
end mute;

architecture Behavioral of mute is
    
    signal mute_check : std_logic := '0';
    
begin

    process(mute_enable, mute_check)
    begin
        
        m_axis_tvalid <= s_axis_tvalid;
        m_axis_tlast <= s_axis_tlast;
        s_axis_tready <= m_axis_tready;
        
        if mute_enable = '1' then
            mute_check <= not mute_check;
        end if;
        
        if mute_check = '0' then
            m_axis_tdata <= s_axis_tdata;
        elsif mute_check = '1' then
            m_axis_tdata <= (Others => '0');
        end if;
        
    end process;
    
end Behavioral;
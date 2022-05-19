library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity led_controller is
    Port ( 
    
        aclk : in std_logic ;
        aresetn : in std_logic ;
                
        mute_enable   : in std_logic;
        filter_enable : in std_logic;
      
        led_r : out std_logic_vector(7 DOWNTO 0);
        led_g : out std_logic_vector(7 DOWNTO 0);
        led_b : out std_logic_vector(7 DOWNTO 0)
    );
end led_controller;

architecture Behavioral of led_controller is

    type led_state_type is (BASE, BASE_WAITING, MUTE_START, MUTE_WAITING, FILTER_START, FILTER_WAITING);
    signal led_state : led_state_type := BASE;
    
    constant LED_ON  : std_logic_vector(7 DOWNTO 0) := (2 DOWNTO 0 => '1', Others => '0');
    constant LED_OFF : std_logic_vector(7 DOWNTO 0) := (Others => '0');
    
    signal filtering : std_logic := '0';
begin
    
    with led_state select led_r <=
        LED_ON when MUTE_START,
        LED_ON when MUTE_WAITING,
        LED_OFF when Others;
    
    with led_state select led_g <=
        LED_ON when BASE,
        LED_ON when BASE_WAITING,
        LED_OFF when Others;
    
    with led_state select led_b <=
        LED_ON when FILTER_START,
        LED_ON when FILTER_WAITING,
        LED_OFF when Others;
        
    process(aclk,aresetn)
    begin
        if aresetn = '0' then 
            led_state <= BASE ;
            filtering <= '0' ;
            
        elsif rising_edge(aclk) then 
        
            case(led_state) is
                when BASE =>
                    if mute_enable = '0' and filter_enable = '0' then
                        led_state <= BASE_WAITING;
                    end if;
                    
                when BASE_WAITING =>
                    if mute_enable = '1' then
                        led_state <= MUTE_START;
                    elsif filter_enable = '1' then
                        led_state <= FILTER_START;
                    end if;
                    
                when MUTE_START =>
                    if mute_enable = '0' then
                        led_state <= MUTE_WAITING;
                    end if;
                    
                when MUTE_WAITING =>
                    if filter_enable = '1' then 
                        filtering <= not filtering ;
                    end if ;
                    if mute_enable = '1' then
                        if filtering = '0' then
                            led_state <= BASE;
                        elsif  filtering = '1' then
                            led_state <= FILTER_START;
                        end if;
                    end if;
                    
                when FILTER_START =>
                    if filter_enable = '0' and mute_enable = '0' then
                        led_state <= FILTER_WAITING;
                        filtering <= '1' ;
                    end if;
                    
                when FILTER_WAITING =>
                    
                    if mute_enable = '1' then
                        led_state <= MUTE_START;                
                    elsif filter_enable = '1' then
                        led_state <= BASE ;
                        filtering <= '0' ;
                    end if;
                    
                when Others =>
                    led_state <= BASE;
                    
            end case;
        
        end if ;
        
        
    end process;

end Behavioral;
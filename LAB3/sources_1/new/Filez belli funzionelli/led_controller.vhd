library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

    constant LED_ON  : std_logic_vector(7 DOWNTO 0) := (Others => '1');
    constant LED_OFF : std_logic_vector(7 DOWNTO 0) := (Others => '0');

    type led_state_type is (BASE, MUTE, FILTER);
    signal led_state : led_state_type := BASE;
    
    -- Since the mute and filter conditions may be overlapped, we need this signal to check whether we should be currently..
    -- .. filtering the data, particularly for when we come out of the mute condition.
    signal filtering : std_logic := '0';
    
begin
    
    -- We use these three select operations to turn on and off the colors of the LED based on the current state.
    with led_state select led_r <=
        LED_ON when MUTE,
        LED_OFF when Others;
    
    with led_state select led_g <=
        LED_ON when BASE,
        LED_OFF when Others;
    
    with led_state select led_b <=
        LED_ON when FILTER,
        LED_OFF when Others;
        
    process(aclk,aresetn)
    begin
       
        if rising_edge(aclk) then 
        
            if aresetn = '0' then 
                led_state <= BASE;
                filtering <= '0';
            
            else
            
                case(led_state) is

                    -- If we press the mute button we'll just go in that state, while if we press the filter button..
                    -- .. we'll also need to keep track of the filtering signal.
                    when BASE =>
                        if mute_enable = '1' then
                            led_state <= MUTE;
                        elsif filter_enable = '1' then
                            led_state <= FILTER;
                            filtering <= '1';
                        end if;
                    
                    -- Whenever we press the filter button while in this state we'll invert the filtering signal, so that..
                    -- .. once we come out of the mute state we'll know whether to go in the base state or in the filter state.
                    when MUTE =>
                        if filter_enable = '1' then 
                            filtering <= not filtering ;
                        end if ;
                        if mute_enable = '1' then
                            if filtering = '0' then
                                led_state <= BASE;
                            elsif filtering = '1' then
                                led_state <= FILTER;
                            end if;
                        end if;
                    
                    -- If we press mute while in FILTER we'll go to MUTE keeping filtering = '1', so that if we come out..
                    -- .. of MUTE right away (or after pressing the joystick button an even number of times) we'll go back to FILTER.
                    when FILTER =>
                        if mute_enable = '1' then
                            led_state <= MUTE;                
                        elsif filter_enable = '1' then
                            led_state <= BASE ;
                            filtering <= '0' ;
                        end if;
                        
                    when Others =>
                        led_state <= BASE;
                        
                end case;
            
            end if;
            
        end if;
        
    end process;

end Behavioral;
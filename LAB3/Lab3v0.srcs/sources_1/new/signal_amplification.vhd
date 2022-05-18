library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity signal_amplification is
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        din_left : in std_logic_vector(24-1 DOWNTO 0);
        din_right : in std_logic_vector(24-1 DOWNTO 0);
        
        amp_power : in integer;
        amp_sign : in std_logic;
        
        balance_check : in std_logic;
        
        dout_left : out std_logic_vector(24-1 DOWNTO 0);
        dout_right : out std_logic_vector(24-1 DOWNTO 0)
    );
end signal_amplification;

architecture Behavioral of signal_amplification is
    
    signal shifter : std_logic_vector(15 DOWNTO 0);
    
    signal zeros : std_logic_vector(15 DOWNTO 0);
    
begin

    process(aclk, aresetn)
    begin
    
        if rising_edge(aclk) then
        
            if aresetn = '0' then
                dout_left <= (Others => '0');
                dout_right <= (Others => '0');
                
            else
            
                if amp_power = 0 then
                    dout_left <= din_left;
                    dout_right <= din_right;
                    
                elsif amp_power > 0 then
                    -- If the amplification power is negative we'll always lower the volume of the right channel
                    if amp_sign = '1' then
                    
                        shifter <= (Others => din_right(23));
--                        dout_right <= shifter(amp_power-1 DOWNTO 0) & din_right(23 DOWNTO amp_power);
                        dout_right(23-amp_power-1 DOWNTO 0)<= din_right(23 DOWNTO amp_power);
                        dout_right(23 DOWNTO amp_power) <= shifter(amp_power-1 DOWNTO 0);
                        
                        -- If we're balancing the output, the left channel will stay as it is.
                        if balance_check = '1' then
                            dout_left <= din_left;
                            
                        -- If we're lowering the volume of both channels, we'll need to shift rightwards the left channel like we did for the right channel
                        elsif balance_check = '0' then
                            shifter <= (Others => din_left(23));
--                            dout_left <= shifter(amp_power-1 DOWNTO 0) & din_left(23 DOWNTO amp_power);
                            dout_left(23-amp_power-1 DOWNTO 0)<= din_left(23 DOWNTO amp_power);
                            dout_left(23 DOWNTO amp_power) <= shifter(amp_power-1 DOWNTO 0);
                        end if;
                        
                    -- If the amplification power is positive...
                    elsif amp_sign = '0' then
                        
                        -- If we're balancing the output, the right channel will stay as it is while the left one will be lowered.
                        if balance_check = '1' then
                            shifter <= (Others => din_left(23));
--                            dout_left <= shifter(amp_power-1 DOWNTO 0) & din_left(23 DOWNTO amp_power);
                            dout_left(23-amp_power-1 DOWNTO 0)<= din_left(23 DOWNTO amp_power);
                            dout_left(23 DOWNTO amp_power) <= shifter(amp_power-1 DOWNTO 0);
                            dout_right <= din_right;
                            
                        -- If we're increasing the volume of both channels, we'll need to shift left both channels while keeping track of possible saturations
                        elsif balance_check = '0' then
                            
                            -- For both channels, whatever the sign of the signal, when we shift leftwards we'll need to add 1 or multiple '0' to the LSBs
                            zeros <= (Others => '0');
                            
                            -- If the channnel won't saturate we may just shift leftwards the signal
                            shifter <= (Others => din_left(23));
                            if din_left(22 DOWNTO 22-amp_power+1) = shifter(amp_power-1 DOWNTO 0) then
                                dout_left <= din_left(23-amp_power DOWNTO 0) & zeros(amp_power-1 DOWNTO 0);
                            -- If the channel does saturate we'll need to assign the highest possible value, whatever the sign of the signal
                            else
                                dout_left <= (23 => din_left(23), Others => not din_left(23));
                            end if;
                            
                            shifter <= (Others => din_right(23));
                            if din_right(22 DOWNTO 22-amp_power+1) = shifter(amp_power-1 DOWNTO 0) then
                                dout_right <= din_right(23-amp_power DOWNTO 0) & zeros(amp_power-1 DOWNTO 0);
                            else
                                dout_right <= (23 => din_right(23), Others => not din_left(23));
                            end if;
                            
                        end if;
                    
                    end if;
                    
                end if;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
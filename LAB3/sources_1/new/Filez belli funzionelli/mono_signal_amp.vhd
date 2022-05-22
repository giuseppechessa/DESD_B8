library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mono_signal_amp is
    Generic(
        -- We only need this generic to determine the width amp_power can reach, e.g. with units = 5 we can achieve..
        -- a max amplification of 2**16, so we'll need 1+log2(16)= 5 bits.
        jstk_units : integer range 5 to 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        din : in std_logic_vector(24-1 DOWNTO 0);
        
        amp_power : in std_logic_vector(9-jstk_units DOWNTO 0);
        amp_sign : in std_logic;
        
        -- channel_check is '0' for the module used for computing data from the left channel and viceversa
        channel_check : in std_logic;
        -- Since volume_control ('0') and balance_control ('1') use instances of this module, we need to know..
        -- .. which one it's being used by.
        balance_check : in std_logic;
        
        dout : out std_logic_vector(24-1 DOWNTO 0)
    );
end mono_signal_amp;

architecture Behavioral of mono_signal_amp is
    
    signal amp_power_int : integer range 0 to 16 := to_integer(unsigned(amp_power));
    
    signal decrease_check : boolean;
    signal increase_check : boolean;
    
    signal dout_sig : signed(23 DOWNTO 0) := (Others => '0');
    signal dout_sat : signed(23 DOWNTO 0) := (Others => '0');
    
begin

    amp_power_int <= to_integer(unsigned(amp_power));
    
    -- We can determine whether we need to increase or decrease the value based on amp_sign, amp_power..
    -- .. channel_check and balance_check, you can find the truth table we used to compute the correct expressions..
    -- .. inside the main .zip
    increase_check <= (balance_check = '0' and amp_sign = '0' and amp_power_int > 0);
    decrease_check <= (amp_sign = '1' or amp_power_int = 0 or balance_check = '1');
    
    process(aclk, aresetn)
    begin
    
        if rising_edge(aclk) then
        
            if aresetn = '0' then
            
                dout <= (Others => '0');
                
            else
            
                if decrease_check = true then
                    
                    -- This condition is based on the fact that when the amp is negative and we're in the left..
                    -- .. channel or viceversa we need to multiply the input by 1 as long as we're balancing the output
                    if balance_check = '1' and amp_sign /= channel_check then
                        dout_sig <= signed(din);
                    else
                        -- This includes the cases where amp_power = 0
                        dout_sig <= shift_right(signed(din), amp_power_int);
                    end if;
                    
                    dout <= std_logic_vector(dout_sig);
                    
                elsif increase_check = true then
                    
                    dout_sig <= shift_left(signed(din), amp_power_int);
                    dout_sat <= (23 => din(23), Others => not din(23));
                    
                    if (din(23) = '0' and dout_sat >= dout_sig and dout_sig > signed(din)) or (din(23) = '1' and dout_sat <= dout_sig and dout_sig < signed(din)) then
                        dout <= std_logic_vector(dout_sig);
                    else
                        dout <= std_logic_vector(dout_sat);
                    end if;
                
                end if;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mono_signal_amp is
    Generic(
        jstk_units : integer range 5 to 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        din : in std_logic_vector(24-1 DOWNTO 0);
        
        amp_power : in std_logic_vector(9-jstk_units DOWNTO 0);
        amp_sign : in std_logic;
        
        channel_check : in std_logic;
        balance_check : in std_logic;
        
        dout : out std_logic_vector(24-1 DOWNTO 0)
    );
end mono_signal_amp;

architecture Behavioral of mono_signal_amp is
    
    signal amp_power_int : integer range 0 to 16 := to_integer(unsigned(amp_power));
    
    signal decrease_check : boolean;
    signal increase_check : boolean;
    
    signal dout_sig : signed(23 DOWNTO 0);
    signal dout_sat : signed(23 DOWNTO 0);
    
begin

    amp_power_int <= to_integer(unsigned(amp_power));
    
    increase_check <= (balance_check = '0' and amp_sign = '0' and amp_power_int > 0);
    decrease_check <= (amp_sign = '1' or amp_power_int = 0 or balance_check = '1');

    process(aclk, aresetn)
    begin
    
        if rising_edge(aclk) then
        
            if aresetn = '0' then
            
                dout <= (Others => '0');
                
            else
            
                if decrease_check = true then
                    
                    if balance_check = '1' and amp_sign /= channel_check then
                        dout_sig <= signed(din);
                    else
                        dout_sig <= shift_right(signed(din), amp_power_int);
                    end if;
                    
                    dout <= std_logic_vector(dout_sig);
                    
                elsif increase_check = true then
                
                    dout_sig <= shift_left(signed(din), amp_power_int);
                    dout_sat <= (23 => din(23), Others => not din(23));
                    
                    if (din(23) = '0' and dout_sat <= dout_sig) or (din(23) = '1' and dout_sat >= dout_sig) then
                        dout <= std_logic_vector(dout_sat);
                    elsif (din(23) = '0' and dout_sat > dout_sig) or (din(23) = '1' and dout_sat < dout_sig) then
                        dout <= std_logic_vector(dout_sig);
                    end if;
                
                end if;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
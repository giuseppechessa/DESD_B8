library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity amp_generator is
    Generic(
        -- We use this interval because any value higher than 9 would give an amplification of 2**0 = 1 for every..
        -- .. value of volume, while any value lower than 5 would create too high of an amplification which would..
        -- .. saturate almost immediatly every kind of input signal. With jstk_units = 6, the max amplification..
        -- .. will be of 2**8 while with jstk_units = 5 we have at most 2**16 which still leaves 8 bits of signal out of the 24.
        jstk_units : integer range 5 TO 9 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        volume : in std_logic_vector(9 DOWNTO 0);

        -- After setting the upper and lower limits for jstk_units, the highest amp_power we can achieve is 16 for jstk_units = 5.
        amp_power : out std_logic_vector(9-jstk_units DOWNTO 0);
        amp_sign : out std_logic
    );
end amp_generator;

architecture Behavioral of amp_generator is
    
    constant CENTER_VALUE : integer := 512;
    
    signal volume_sym_int : integer;
    signal volume_sym : signed(9 DOWNTO 0);
    signal volume_div : signed(9 DOWNTO 0);
    
    signal amp_check : signed(1 DOWNTO 0);
    signal amp_sig : integer;
    
begin
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                amp_power <= (Others => '0');
                
            else
                
                volume_sym_int <= to_integer(unsigned(volume)) - CENTER_VALUE;
                
                volume_sym <= to_signed(volume_sym_int, 10);
                
                amp_check(1 DOWNTO 0) <= volume_sym(jstk_units DOWNTO jstk_units-1);
                
                volume_div <= shift_right(volume_sym, jstk_units);
                
                if amp_check = "00" or amp_check = "10" then
                    amp_sig <= to_integer(volume_div);
                elsif amp_check = "01" or amp_check = "11" then
                    amp_sig <= to_integer(volume_div) + 1;
                end if;
                
                if amp_sig < 0 then
                    amp_power <= std_logic_vector(to_signed(-amp_sig, amp_power'LENGTH));
                    amp_sign <= '1';
                elsif amp_sig >= 0 then
                    amp_power <= std_logic_vector(to_signed(amp_sig, amp_power'LENGTH));
                    amp_sign <= '0';
                end if;
                
            end if;
        
        end if;
         
    end process;

end Behavioral;
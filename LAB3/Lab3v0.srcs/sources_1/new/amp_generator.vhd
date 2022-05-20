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
        -- We need 5 bits for amp_power in case we use jstk_unit = 5, otherwise we would need
        amp_power : out std_logic_vector(9-jstk_units DOWNTO 0);
        amp_sign : out std_logic
    );
end amp_generator;

architecture Behavioral of amp_generator is
    
    constant CENTER_VALUE : integer := 512;
    
    signal shifter : std_logic_vector(jstk_units-1 DOWNTO 0);
    
    signal volume_sym_int : integer;
    signal volume_sym : std_logic_vector(9 DOWNTO 0);
    signal volume_div : std_logic_vector(9 DOWNTO 0);
    
    signal amp_check : std_logic_vector (1 DOWNTO 0);
    signal amp_sig : integer;
    
begin
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                amp_power <= (Others => '0');
                
            else
                
                volume_sym_int <= to_integer(unsigned(volume)) - CENTER_VALUE;
                volume_sym <= std_logic_vector(to_signed(volume_sym_int, 10));
                
                if volume_sym_int < 0 then
                    shifter <= (Others => '1');
                elsif volume_sym_int >= 0 then
                    shifter <= (Others => '0');
                end if;
                
                volume_div <= shifter & volume_sym(9 DOWNTO jstk_units);
                
                amp_check(1 DOWNTO 0) <= volume_sym(jstk_units DOWNTO jstk_units-1);
                
                if amp_check = "00" or amp_check = "10" then
                    amp_sig <= to_integer(signed(volume_div));
                elsif amp_check = "01" or amp_check = "11" then
                    amp_sig <= to_integer(signed(volume_div)) + 1;
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
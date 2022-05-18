library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity amp_generator is
    Generic(
        -- Since the number of intervals in the range 0 TO 1023 is given by 1024/(2**units)..
        -- .. it might make more sense to keep the range of jstk_units such that by raising the volume to..
        -- .. the highest possible value we don't automatically saturate the signal (with units = 4 we would have..
        -- .. 64 total intervals which equate to a maximum amplification of 2**32 which would saturate even the..
        -- .. lowest possible signal.
        jstk_units : integer range 5 TO 10 := 6
    );
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        volume : in std_logic_vector(9 DOWNTO 0);
        
        amp_power : out integer;
        amp_sign : out std_logic
    );
end amp_generator;

architecture Behavioral of amp_generator is
    
    constant CENTER_VALUE : integer := 512;
    
    signal shifter : std_logic_vector(jstk_units-1 DOWNTO 0);
    
    signal volume_sym_int : integer;
    signal volume_sym : std_logic_vector(9 DOWNTO 0);
    signal volume_div : std_logic_vector(9 DOWNTO 0);
    
    signal amp_check : std_logic;
    signal amp_sig : integer;
    
begin
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                amp_power <= 0;
                
            else
                
                volume_sym_int <= to_integer(unsigned(volume)) - CENTER_VALUE;
                volume_sym <= std_logic_vector(to_signed(volume_sym_int, 10));
                
                if volume_sym_int < 0 then
                    shifter <= (Others => '1');
                elsif volume_sym_int >= 0 then
                    shifter <= (Others => '0');
                end if;
                
                volume_div <= shifter & volume_sym(9 DOWNTO 9-jstk_units+3);
                
                amp_check <= volume_sym(9-jstk_units+2);
                
                if amp_check = '0' then
                    amp_sig <= to_integer(signed(volume_div));
                elsif amp_check = '1' then
                    amp_sig <= to_integer(signed(volume_div)) + 1;
                end if;
                
                if amp_sig < 0 then
                    amp_power <= -amp_sig;
                    amp_sign <= '1';
                elsif amp_sig >= 0 then
                    amp_power <= amp_sig;
                    amp_sign <= '0';
                end if;
                
            end if;
        
        end if;
         
    end process;

end Behavioral;
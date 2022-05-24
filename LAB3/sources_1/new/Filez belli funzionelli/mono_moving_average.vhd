library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity mono_moving_average is
    Generic(
		DATA_LENGTH		: Integer := 24;
		CLK_FREQUENCY 	: Integer := 100_000_000;
        n_samples 		: integer := 32
    );
    Port (
        aclk     		: in std_logic;
        aresetn     	: in std_logic;
        
        filter_enable 	: in std_logic;
        
        din 			: in  std_logic_vector(DATA_LENGTH-1 DOWNTO 0);
        dout 			: out std_logic_vector(DATA_LENGTH-1 DOWNTO 0)
    );
end mono_moving_average;

architecture Behavioral of mono_moving_average is
	
	-- CONSTANT DECLARATION --
	-- extra bits needed fot the sum of the 32 samples  
	constant extra_bits : integer := integer(log2(real(n_samples)));
	
	-- Audio sampling rate
	constant Audio_Frequency : integer := 44_100;
	
	--Maximum Frequency rated in this block is 300MHz so 
	constant Counter_Up_Value_un : unsigned(12 downto 0):= to_unsigned(CLK_FREQUENCY/Audio_Frequency,13);
    
	
	-- SIGNALS --
	-- we need this signal to know when the filtering action is active 
    signal filter_check : std_logic := '0';
    
	-- memory to store the 32 samples and compute the moving average 
    type filter_type is array(n_samples-1 DOWNTO 0) of signed(DATA_LENGTH-1 DOWNTO 0);
    signal filter_mem : filter_type := (Others => (Others => '0'));
    
	-- signal for the sum of the samples 
    signal sum : signed(DATA_LENGTH-1 + extra_bits DOWNTO 0) := (Others => '0');

	-- Since the samples rate is lower than the clk frequency we need a counter that show us how many clk cycles ...
	--	... there are before the new sample, to properly store the data in memory. 
    signal count : unsigned(12 downto 0) := (Others => '0') ;

begin

    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
            
            if aresetn = '0' then
                filter_mem   <= (Others => (Others => '0'));
                sum          <= (Others => '0');
                filter_check <= '0';
				count        <= (Others => '0') ;
                
            else
			
				-- when the filter_enable is high we change the status of filtering : if filter_check = '1' the filtering is active ...
				-- ... when filter_check = '0' there is no filtering. 
                if filter_enable = '1' then
                    filter_check <= not filter_check;
                end if;
				
				count <= count + 1 ;
				
				-- When we reach the value CLK_FREQUENCY/Audio_Frequency we use the new sample to update the sum and the memory 
                if count = Counter_Up_Value_un then 
				
                    -- We add the new value to the current total sum while at the same time we get rid of the oldest value
                    sum        <= sum - signed(filter_mem(filter_mem'HIGH)) + signed(din);
					
                    -- We perform the replacement in the memory as well
                    filter_mem <= filter_mem(filter_mem'HIGH-1 DOWNTO 0) & signed(din);
					
					-- Since we collect the new sample we reset the count to zero 
                    count      <= (Others => '0') ;
                end if ;
				
                if filter_check = '1' then
                    -- The output is made by the sum of the n_samples current values in the memory, shifted rightwards by extra_bits
                    dout <= std_logic_vector(sum(sum'HIGH DOWNTO extra_bits)); 
                else
                    -- If we're not enabling the computation, we may send the inout data to the output as it is.
                    dout <= din;
                end if;
                
            end if;
            
        end if;
            
    end process;

end Behavioral;
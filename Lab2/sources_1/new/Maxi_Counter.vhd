library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.MATH_REAL.ALL;
	
entity Maxi_Counter is
  Generic(
		NUM_OF_PULSES	    :	POSITIVE	:= 1e6;	-- Number of clock cycles between two register shifts at base speed
		NUM_OF_SWS			:	INTEGER		RANGE	1 TO 16 := 16	-- Number of input switches
  );
  Port (
		clk			:	in	std_logic;
		reset		:	in	std_logic;
		
		switches	:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
		enable		:	out	std_logic
  );
end Maxi_Counter;

architecture Behavioral of Maxi_Counter is

    constant Zero_Value         :   unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others => '0');

	-- Base Counter used to count the number of clock cycles between register shifts at base speed
	signal Primary_Counter	:	unsigned(integer(floor(log2(real(NUM_OF_PULSES)))) DOWNTO 0):= (Others => '0');
	-- When any switch is on, this additional Counter counts the number of times PrimaryCounter has counted to NUM_OF_PULSES
	signal Secondary_Counter	:	unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others => '0');

	-- Equivalent numerical value determined by the Switches
	signal Switches_Value	    :	unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others => '0');
	
	signal Enable_Reg    	    :	std_logic := '0';
	
begin

    enable <= Enable_Reg;
    
	process (clk, reset)
	begin
	    -- Whenever we press reset, we reset both counters and check if the switches have changed
		if reset = '1' then
		
			Enable_Reg <= '0';
			
			Primary_Counter <= (Others => '0');
			Secondary_Counter <= (Others => '0');
			
			Switches_Value <= unsigned(switches);
			
		elsif rising_edge(clk) then
		
			Enable_Reg <= '0';
			Primary_Counter <= Primary_Counter + 1;
			
			-- When the first counter completes a full loop we reset it to 0 and increase the second counter by 1
			if Primary_Counter >= to_unsigned(NUM_OF_PULSES-1, Primary_Counter'LENGTH) then
			
				Primary_Counter <= (Others => '0');
				Secondary_Counter <= Secondary_Counter + 1;
				
				-- We can only activate the enable if the second counter has reached the value represented by the switches
				if Secondary_Counter >= unsigned(Switches_Value) then
					Secondary_Counter <= (Others => '0');
					Enable_Reg<='1';
				end if;
				
			end if;
			
			-- We check to see if the switches have been changed only at the end of each complete loop,  i.e. ehen enable has been activated, and at the beginning
			if Secondary_Counter = Zero_Value then
				Switches_Value <= unsigned(switches);
			end if;
			
		end if;
		
	end process;

end Behavioral;
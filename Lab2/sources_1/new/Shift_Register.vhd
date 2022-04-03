library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;

entity Shift_Register is
	Generic(
		NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16	-- Number of output LEDs
	);
    Port ( 
		clk		:in 	std_logic;
        reset	:in 	std_logic;
		
		enable	:in		std_logic;	-- Uses the output of Maxi_Counter to determine when we can shift the registers

		Led_Out	:out	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0)
	);
end Shift_Register;

architecture Behavioral of Shift_Register is

	signal SR_internal	:	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0) := (0 => '1', Others => '0');

	type Type_Dir is (GOING_RIGHT, GOING_LEFT);
	signal Direction    :   Type_Dir := GOING_LEFT;

begin

	NUM_LEDS_ONE :      if NUM_OF_LEDS = 1 generate
		Led_Out <= (Others => '1');
	end generate;
	
	NUM_LEDS_MULTIPLE : if NUM_OF_LEDS > 1 generate
	
		Led_out <= SR_Internal;
		
		process (clk,reset)
		begin

			if reset = '1' then
			    -- With a tail made by N LEDs we'll instantiate N SR, the one with the most intense PWM as input is initially placed on the MSB
				SR_Internal <= (0 => '1', Others => '0');

				direction <= GOING_RIGHT;

			elsif rising_edge(clk) then
				-- We'll apply a shift only whenever Counter enables it, in our case only when dtx has passed
				if enable = '1' then 
				    
				    -- The Vector is shifted depending on the direction
					if direction = GOING_LEFT then  
						SR_Internal <= SR_Internal(NUM_OF_LEDS - 2 DOWNTO 0) & '0';
					elsif direction = GOING_RIGHT then
						SR_Internal <= '0' & SR_Internal(NUM_OF_LEDS - 1 DOWNTO 1);
					end if;
					
					-- We switch direction whenever the single active LED of this instance approaches one of the two ends
					if SR_Internal(SR_internal'HIGH - 1) = '1' AND direction = GOING_LEFT  then
						direction <= GOING_RIGHT;
					elsif SR_Internal(SR_internal'LOW + 1) = '1' AND direction = GOING_RIGHT then
					    direction <= GOING_LEFT;
					end if;
					
				end if;
				
			end if;
			
		end process;
		
	end generate;

end Behavioral;
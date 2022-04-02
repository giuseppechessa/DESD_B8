library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;

entity Shift_Register is
	Generic(
		NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16	-- Number of output LEDs
	);
    Port ( 
		clk		:in 	std_logic;
        reset	:in 	std_logic;
		
		enable	:in		std_logic;
		Led_Out	:out	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0)
	);
end Shift_Register;

architecture Behavioral of Shift_Register is
	signal SR_internal	:	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0) := (0=>'1', Others=>'0');
	signal direction	:	std_logic:='0';
begin
	NUM_LEDS_ONE: if NUM_OF_LEDS=1 generate
		LED_OUT<=(Others=>'1');
	end generate;
	NUM_LEDS_MULTIPLE: if NUM_OF_LEDS>1 generate
		Led_out<=SR_internal;
		process (clk,reset)
		begin
			
			
			if reset='1' then
				SR_internal<= (0=>'1', Others=>'0');
				direction<='0';
			elsif rising_edge(clk) then
				if enable = '1' then 
					if direction = '0' then
						SR_Internal(SR_Internal'LOW)<='0';
						for I in 0 to SR_internal'HIGH-1 loop
							SR_internal(I+1)<=SR_internal(I);
						end loop;
					elsif direction = '1' then
						SR_Internal(SR_Internal'HIGH)<='0';
						for I in 0 to SR_internal'HIGH-1 loop
							SR_internal(I)<=SR_internal(I+1);
						end loop;
					end if;
					if (SR_Internal(SR_internal'HIGH-1)='1' AND direction='0') or (SR_Internal(SR_internal'LOW+1)='1' AND direction='1') then
						direction<= not direction;
					end if;
				end if;
			end if;
		end process;
	end generate;


end Behavioral;

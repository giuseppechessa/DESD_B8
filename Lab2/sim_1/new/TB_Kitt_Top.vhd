library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Kitt_Top is
--  Port ( );
end TB_Kitt_Top;

architecture Behavioral of TB_Kitt_Top is
    
    -- Declaration of the module
	component Kitt_Top is
		Generic (
			CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100     := 10;	-- clk Period in nanoseconds
			MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

			NUM_OF_SWS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of input switches
			NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of output LEDs
			
			TAIL_LENGTH		:	INTEGER		RANGE	1 TO 16		:= 4	-- Tail length
		);
		Port (
			reset	:	IN	STD_LOGIC;
			clk		:	IN	STD_LOGIC;

			sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	-- Switches avaiable on Basys3
			leds	:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	-- LEDs avaiable on Basys3
		);
	end component;
	
	--We instantiate the constant and signals we'll need to execute the TB, including the clk time and the length of the Kitt's tail
	constant CLKPERIOD				:	Time := 10ns;
	
	constant CLK_PERIOD_NS 			:	POSITIVE := 10;
	constant MIN_KITT_CAR_STEP_MS 	:	POSITIVE := 1;
	
	constant NUM_OF_SWS 			:	INTEGER := 16;
	constant NUM_OF_LEDS 			:	INTEGER := 16;
	constant TAIL_LENGTH            :   INTEGER := 4;
		
	signal reset	: std_logic := '0';
	signal clk		: std_logic := '1';
	
	signal sw		: std_logic_vector(NUM_OF_SWS-1 downto 0);
	signal leds		: std_logic_vector(NUM_OF_LEDS-1 downto 0);
	
	-- We'll modify this signal in the Testbench's process to modify the speed of the Kitt Car Effect
	signal SW_Int	: INTEGER;
	
begin
    
    clk <= not clk after CLKPERIOD/2;
    
    -- Instantiation of the DUT
	Kitt_Top_INST : Kitt_Top
	generic map(
		CLK_PERIOD_NS => CLK_PERIOD_NS,
		MIN_KITT_CAR_STEP_MS => MIN_KITT_CAR_STEP_MS,
		NUM_OF_SWS => NUM_OF_SWS,
		NUM_OF_LEDS => NUM_OF_LEDS,
		TAIL_LENGTH => TAIL_LENGTH
	)
	port map(
		reset => reset,
		clk => clk,
		sw => sw,
		leds => leds
	);
	
	sw <= std_logic_vector(to_unsigned(SW_Int, sw'LENGTH));
	
	--Run the simulation for at least 100ms to see the LEDs moving at base speed and at 5 times lower speed
	process
	begin
	
	reset <= '1';      --At first we reset the program and we set SW=0 to see the LEDs change at base speed
	SW_Int <= 0;
	wait for 100ns;
	
	reset <= '0';
	wait for 40ms;
	
	reset <= '1';      --Then we decrease the speed between each shift of the LEDs, resetting again to be sure that the counters start up properly
	SW_Int <= 4;
	wait for 100ns;
		
	reset <= '0';
	wait for 50ms;
	
	reset <= '1';      --Once again we slow down the Kitt's speed, this time every shift takes (14+1)*1ms = 15ms
	SW_Int <= 14;
	wait for 100ns;
		
	reset <= '0';
	wait;
	
	end process;

end Behavioral;

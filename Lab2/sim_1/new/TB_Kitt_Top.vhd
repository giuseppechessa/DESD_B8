library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Kitt_Top is
--  Port ( );
end TB_Kitt_Top;

architecture Behavioral of TB_Kitt_Top is
    
    ---- DUT ----
	component Kitt_Top is
		Generic (
			CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100     := 10;	-- clk Period in nanoseconds
			MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

			NUM_OF_SWS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of input switches
			NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of output LEDs
			
			TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16	:= 4	-- Tail length
		);
		Port (
			reset	:	IN	STD_LOGIC;
			clk		:	IN	STD_LOGIC;

			sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	-- Switches avaiable on Basys3
			leds	:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	-- LEDs avaiable on Basys3
		);
	end component;
	
	---- CONSTANT DECLARATION ----
	-- Timing
	constant CLKPERIOD				:	Time := 10ns;
	
	-- DUT Generics
	constant DUT_CLK_PERIOD_NS 			:	POSITIVE := 10;
	constant DUT_MIN_KITT_CAR_STEP_MS 	:	POSITIVE := 1;
	constant DUT_NUM_OF_SWS 			:	INTEGER := 16;
	constant DUT_NUM_OF_LEDS 			:	INTEGER := 16;
	constant DUT_TAIL_LENGTH            :   INTEGER := 4;
	
	--- SIGNALS DECLARATION ---
	signal reset	: std_logic := '0';
	signal clk		: std_logic := '1';
	
	signal dut_sw		: std_logic_vector(NUM_OF_SWS-1 downto 0);
	signal dut_leds		: std_logic_vector(NUM_OF_LEDS-1 downto 0);
	
	-- We'll modify this signal in the Testbench's process to modify the speed of the Kitt Car Effect
	signal SW_Int	: INTEGER;
	
begin
    -- clock
    clk <= not clk after CLKPERIOD/2;
    
    --- DUT ---
	Kitt_Top_INST : Kitt_Top
	generic map(
		CLK_PERIOD_NS		 => DUT_CLK_PERIOD_NS,
		MIN_KITT_CAR_STEP_MS => DUT_MIN_KITT_CAR_STEP_MS,
		NUM_OF_SWS 			 => DUT_NUM_OF_SWS,
		NUM_OF_LEDS 	     => DUT_NUM_OF_LEDS,
		TAIL_LENGTH 		 => DUT_TAIL_LENGTH
	)
	port map(
		reset 	=> reset,
		clk 	=> clk,
		sw 		=> dut_sw,
		leds 	=> dut_leds
	);
	
	dut_sw <= std_logic_vector(to_unsigned(SW_Int, dut_sw'LENGTH));
	
	-- Stimulus process
	stim_proc: process
	begin
		
		-- start
		reset <= '1';      --At first we reset the program and we set SW=0 to see the LEDs change at base speed
		SW_Int <= 0;
		wait for 100ns;
		
		reset <= '0';
		wait for 10ms;
		
		reset <= '1';      --Then we decrease the speed between each shift of the LEDs, resetting again to be sure that the counters start up properly
		SW_Int <= 4;
		wait for 100ns;
			
		reset <= '0';
		wait for 20ms;
		
		reset <= '1';      --Once again we slow down the Kitt's speed, this time every shift takes (14+1)*1ms = 15ms
		SW_Int <= 14;
		wait for 100ns;
			
		reset <= '0';
		
		-- stop
		wait;
	
	end process;

end Behavioral;

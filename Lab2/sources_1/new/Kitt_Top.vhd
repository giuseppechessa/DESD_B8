library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;


entity Kitt_Top is
	Generic (

		CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100     := 10;	-- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

		NUM_OF_SWS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of input switches
		NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16	-- Number of output LEDs

	);
	Port (
		reset	:	IN	STD_LOGIC;
		clk		:	IN	STD_LOGIC;

		sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	-- Switches avaiable on Basys3
		leds	:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	-- LEDs avaiable on Basys3
	);
end Kitt_Top;

architecture Behavioral of Kitt_Top is
	component Shift_Register is
		Generic(
			NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16	-- Number of output LEDs
		);
		Port ( 
			clk		:in 	std_logic;
			reset	:in 	std_logic;
			
			enable	:in		std_logic;
			Led_Out	:out	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0)
		);
	end component;
	
	component Maxi_Counter is
	  Generic(
			Number_Of_Pulses	:	POSITIVE	:= 1e6;
			NUM_OF_SWS			:	INTEGER		RANGE	1 TO 16 := 16	-- Number of input switches
	  );
	  Port (
			clk		:	in	std_logic;
			reset	:	in	std_logic;
			
			Switches	:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
			enable	:	out	std_logic
	  );
	end component;

	constant Number_Of_Pulses : Integer := 1e6*MIN_KITT_CAR_STEP_MS/CLK_PERIOD_NS;
	signal enable	: std_logic;
begin

	SR_INST : Shift_Register
	generic map(
		NUM_OF_LEDS=>NUM_OF_LEDS
	)
	port map(
		clk=>clk,
		reset=>reset,
		enable=>enable,
		Led_Out=>leds
	);
	
	Maxi_Counter_INST : Maxi_Counter
	generic map(
		Number_Of_Pulses=>Number_Of_Pulses,
		NUM_OF_SWS=>NUM_OF_SWS
	)
	port map(
		clk=>clk,
		reset=>reset,
		Switches=>sw,
		enable=>enable
	);


end Behavioral;

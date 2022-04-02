library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Kitt_Top is
--  Port ( );
end TB_Kitt_Top;

architecture Behavioral of TB_Kitt_Top is
	component Kitt_Top is
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
	end component;
	
	constant CLKPERIOD				:	Time:=10ns;
	constant CLK_PERIOD_NS 			:	POSITIVE:= 10;
	constant MIN_KITT_CAR_STEP_MS 	:	POSITIVE:= 1;
	constant NUM_OF_SWS 			:	INTEGER:= 16;
	constant NUM_OF_LEDS 			:	INTEGER:= 16;
		
	signal reset	: std_logic:='0';
	signal clk		: std_logic:='1';
	signal sw		:	std_logic_vector(NUM_OF_SWS-1 downto 0);
	signal leds		:	std_logic_vector(NUM_OF_LEDS-1 downto 0);
	
	signal SW_Int	:INTEGER;
	
begin
	Kitt_Top_INST : Kitt_Top
	generic map(
		CLK_PERIOD_NS=>CLK_PERIOD_NS,
		MIN_KITT_CAR_STEP_MS=>MIN_KITT_CAR_STEP_MS,
		NUM_OF_SWS=>NUM_OF_SWS,
		NUM_OF_LEDS=>NUM_OF_LEDS
	)
	port map(
		reset=>reset,
		clk=>clk,
		sw=>sw,
		leds=>leds
	);
	
	clk<=not clk after CLKPERIOD/2;
	sw<=std_logic_vector(to_unsigned(SW_Int,sw'LENGTH));
	process
	begin
	SW_Int<=1;
	wait;
	end process;

end Behavioral;

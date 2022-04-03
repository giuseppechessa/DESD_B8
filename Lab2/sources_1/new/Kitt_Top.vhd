library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.ALL;

entity Kitt_Top is
	Generic (

		CLK_PERIOD_NS			:	POSITIVE	RANGE	1 TO 100    := 10;	-- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1 TO 2000   := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

		NUM_OF_SWS				:	INTEGER		RANGE	1 TO 16 	:= 16;	-- Number of input switches
		NUM_OF_LEDS				:	INTEGER		RANGE	1 TO 16 	:= 16;	-- Number of output LEDs
		TAIL_LENGTH				:	INTEGER		RANGE	1 TO 16		:= 4	-- Tail length

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
	
	component Mini_Counter is
		Generic(
			TAIL_LENGTH				:	INTEGER	RANGE	1 TO 16	:= 4	-- Tail length
		);
		Port ( 
			clk		: 	in 	std_logic;
			reset	: 	in 	std_logic;
			din		:	in	std_logic;
			enable	:	in	std_logic;
			dout	:	out	std_logic_vector(integer(floor(log2(real(TAIL_LENGTH)))) DOWNTO 0)
		);
	end component;
	
	component PWM is
	  GENERIC(
		BIT_LENGTH : INTEGER RANGE 1 TO 16 := 8;
		T_ON_INIT  : POSITIVE :=64;
		PERIOD_INIT : POSITIVE := 128;
		PWM_INIT    : std_logic:='0'
	  );
	  Port (
		reset : in  std_logic;
		clk   : in  std_logic;
		Ton   : in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0):=std_logic_vector(to_unsigned(T_ON_INIT,BIT_LENGTH));
		Period: in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0):=std_logic_vector(to_unsigned(PERIOD_INIT,BIT_LENGTH));
		PWM   : out std_logic:=PWM_INIT
	   );
	end component;
    
    constant Tail_BITS	        :   Integer			:= integer(floor(log2(real(TAIL_LENGTH))));
	constant Period				:	Integer			:= TAIL_LENGTH;
	constant Period_PWM			:	std_logic_vector(Tail_BITS DOWNTO 0)		:= std_logic_vector(to_unsigned(Period,Tail_BITS+1));
	constant Number_Of_Pulses	: 	Integer 		:= 1e6*MIN_KITT_CAR_STEP_MS/CLK_PERIOD_NS;
	
	
	type   Couner_exit is array(Integer range <>) of std_logic_vector(Tail_BITS DOWNTO 0);
	signal enable				: 	std_logic;
	signal Led_Out				:	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0);
	signal dout					:	Couner_exit(NUM_OF_LEDS-1 DOWNTO 0);
begin

	SR_INST : Shift_Register
	generic map(
		NUM_OF_LEDS=>NUM_OF_LEDS
	)
	port map(
		clk=>clk,
		reset=>reset,
		enable=>enable,
		Led_Out=>Led_Out
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
	
	MiniCounterANDPwm: for I in 0 to NUM_OF_LEDS-1 generate
		Mini_Counter_INST	:Mini_Counter
		generic map(
			TAIL_LENGTH=>TAIL_LENGTH
		)
		port map(
			reset=>reset,
			clk=>clk,
			din=>Led_Out(I),
			enable=>enable,
			dout=>dout(I)
		);
		
		PWM_INST 	:PWM
		generic map(
			BIT_LENGTH=>Period_PWM'LENGTH,
			T_ON_INIT=>1,
			PERIOD_INIT=>TAIL_LENGTH,
			PWM_INIT=>'1'		
		)
		port map(
			reset=>reset,
			clk=>clk,
			Ton=>dout(I),
			Period=>Period_PWM,
			PWM=>leds(I)
		);
		
	end generate;


end Behavioral;

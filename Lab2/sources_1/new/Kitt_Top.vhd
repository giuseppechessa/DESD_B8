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

		TAIL_LENGTH				:	INTEGER		RANGE	1 TO 16		:= 8	-- Tail length
	);
	Port (
		reset	:	IN	STD_LOGIC;
		clk		:	IN	STD_LOGIC;

		sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	-- Switches available on Basys3
		leds	:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	-- LEDs available on Basys3
	);
end Kitt_Top;

architecture Behavioral of Kitt_Top is

	-- COMPONENTS -- 
	component Shift_Register is
		Generic(
			NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16	
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
			NUM_OF_PULSES	:	POSITIVE	:= 1e5;
			NUM_OF_SWS		:	INTEGER		RANGE	1 TO 16 := 16	
		);
		Port (
			clk			:	in	std_logic;
			reset		:	in	std_logic;
			
			Switches	:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
			enable		:	out	std_logic
		);	
	end component;
	
	
	component Mini_Counter is
		Generic(
			TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16	:= 4	
		);
		Port ( 
			clk		: 	in 	std_logic;
			reset	: 	in 	std_logic;

			din		:	in	std_logic;
			enable	:	in	std_logic;

			dout	:	out	std_logic_vector(integer(log2(real(TAIL_LENGTH))) DOWNTO 0)
		);
	end component;
	
	
	component PWM is
		GENERIC(
			BIT_LENGTH 	: INTEGER RANGE 1 TO 16 := 8;

			T_ON_INIT  	: POSITIVE 				:= 64;
			PERIOD_INIT : POSITIVE 				:= 128;

			PWM_INIT    : std_logic				:='0'
		);
		Port (
			reset 	: in  std_logic;
			clk   	: in  std_logic;

			Ton   	: in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0) := std_logic_vector(to_unsigned(T_ON_INIT,BIT_LENGTH));
			Period	: in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0) := std_logic_vector(to_unsigned(PERIOD_INIT,BIT_LENGTH));

			PWM  	: out std_logic							      := PWM_INIT
		);
	end component;
	

    -- CONSTANT DECLARATION --
	-- Number of bits needed to represent TAIL_LENGTH
    constant TAIL_BITS	        :   Integer								:= integer(log2(real(TAIL_LENGTH))); 
	
	-- Period of PWM with value TAIL_LENGTH 
	constant PERIOD				:	Integer								:= TAIL_LENGTH;
	constant PERIOD_PWM			:	std_logic_vector(TAIL_BITS DOWNTO 0):= std_logic_vector(to_unsigned(PERIOD, TAIL_BITS + 1));
	
	-- Number of clock cycles between two register shifts
	constant NUM_OF_PULSES		: 	Integer 							:= 1e6 * MIN_KITT_CAR_STEP_MS / CLK_PERIOD_NS;
	
	
	-- SIGNALS --
	-- Enable signal 
	signal Enable_Sig			: 	std_logic;
	
	-- Mini_Counter output signal 
	type   Counter_exit is array(Integer range <>) of std_logic_vector(TAIL_BITS DOWNTO 0);
	signal Ton_Sig				:	Counter_exit(NUM_OF_LEDS-1 DOWNTO 0);
	
	-- Shift_Register output signal, Mini_Counter input signal 
	signal Led_Out				:	std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0);

begin
	
	-- INSTANCES --
	-- Shift Register will implement the Kitt Car effect
	SR_INST : Shift_Register
		generic map(
			NUM_OF_LEDS => NUM_OF_LEDS
		)
		port map(
			clk		=> clk,
			reset	=> reset,
			enable	=> Enable_Sig,
			Led_Out	=> Led_Out
		);
	
	-- Maxi Counter will create an enable output that allow us to perform the operations with the proper timing
	Maxi_Counter_INST : Maxi_Counter
		generic map(
			NUM_OF_PULSES 	=> NUM_OF_PULSES,
			NUM_OF_SWS		=> NUM_OF_SWS
		)
		port map(
			clk		 => clk,
			reset	 => reset,
			Switches => sw,
			enable	 => Enable_Sig
		);
	
	-- Tail instantiation 
	MiniCounterANDPwm : for I in 0 to NUM_OF_LEDS-1 generate
		
		-- Mini_Counter to generate the Ton value for PWM
		Mini_Counter_INST : Mini_Counter
			generic map(
				TAIL_LENGTH => TAIL_LENGTH
			)
			port map(
				reset	=> reset,
				clk		=> clk,
				din		=> Led_Out(I),
				enable	=> Enable_Sig,
				dout	=> Ton_Sig(I)
			);
		
		-- PWM effect
		PWM_INST : PWM
			generic map(
				BIT_LENGTH	=> PERIOD_PWM'LENGTH,
				T_ON_INIT	=> 1,
				PERIOD_INIT	=> TAIL_LENGTH,
				PWM_INIT	=> '1'		
			)
			port map(
				reset	=> reset,
				clk		=> clk,
				Ton		=> Ton_Sig(I),
				Period	=> PERIOD_PWM,
				PWM		=> leds(I)
			);
		
	end generate;

end Behavioral;
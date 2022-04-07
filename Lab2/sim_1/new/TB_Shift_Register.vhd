library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Shift_Register is
--  Port ( );
end TB_Shift_Register;

architecture Behavioral of TB_Shift_Register is

	---- DUT ----
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
	
	---- CONSTANT DECLARATION ----
	-- Timing
	constant CLK_Period		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	-- DUT Generics
	constant DUT_NUM_OF_LEDS	: INTEGER := 16;
	
	--- SIGNALS DECLARATION ---
	signal clk		: std_logic := '1';
	signal reset	: std_logic :='0';
			
	signal dut_enable	: std_logic;
	signal dut_Led_Out	: std_logic_vector(DUT_NUM_OF_LEDS-1 DOWNTO 0);
	
	
begin

	--- DUT ---
	Inst_SR : Shift_Register
		generic map(
			NUM_OF_LEDS => DUT_NUM_OF_LEDS
		)
		port map(
			clk		=> clk,
			reset	=> reset,
			enable	=> dut_enable,
			Led_Out	=> dut_Led_Out
		);

	--- TEST BENCH DATA FLOW  ---
	-- clock
	clk <= not clk after CLK_Period/2;
	
	
	-- Reset Process 
	reset_wave :process
	begin
		reset <= '1';
		wait for RESET_WND;
		
		reset <= '0';
		wait;
    end process ;
	

	-- Stimulus process
	
	process
	begin
	
		-- waiting the reset wave
		dut_enable <= '0';
		wait for RESET_WND;
		
		-- start
		dut_enable <= '1';
		wait for CLK_Period*10 ;
		
		dut_enable <= '0' ;
		wait for CLK_Period*2 ;
		
		dut_enable <= '1' ;
		
		-- stop
		wait;
	end process;

end Behavioral;
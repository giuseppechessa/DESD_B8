library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Maxi_Counter is
--  Port ( );
end TB_Maxi_Counter;

architecture Behavioral of TB_Maxi_Counter is
	
	---- DUT ----
	component Maxi_Counter is
	  Generic(
			NUM_OF_PULSES		:	POSITIVE	:= 1e6;					-- Number of clock cycles between two register shifts at base speed
			NUM_OF_SWS			:	INTEGER		RANGE	1 TO 16 := 16	-- Number of input switches
	  );
	  Port (
			clk					:	in	std_logic;
			reset				:	in	std_logic;
			
			Switches			:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
			enable				:	out	std_logic
	  );
	end component;
	
	
	---- CONSTANT DECLARATION ----
	-- Timing
	constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	-- DUT Generics
	constant DUT_NUM_OF_PULSES	: POSITIVE := 1e5;
	constant DUT_NUM_OF_SWS		: POSITIVE := 16;
	
	
	
	--- SIGNALS DECLARATION ---
	
	signal clk			:	std_logic:= '1';
	signal reset		:	std_logic:= '0';
	
	signal dut_Switches	:	std_logic_vector(DUT_NUM_OF_SWS-1 DOWNTO 0);
	signal dut_enable	:	std_logic := '0';
	
	signal Switches_int	:	integer;			-- switches integer value 
	
begin

	--- DUT ---
	Inst_Maxi_Counter	: Maxi_Counter
		generic map(
			NUM_OF_PULSES => DUT_NUM_OF_PULSES,
			NUM_OF_SWS	  => DUT_NUM_OF_SWS
		)
		port map(
			clk		=>clk,
			reset	=>reset,
			
			Switches=>dut_Switches,
			enable	=>dut_enable
		);
	
	
	--- TEST BENCH DATA FLOW  ---
	-- clock
	clk	<=	not clk after CLK_PERIOD/2;
	
	-- Reset Process 
	reset_wave :process
	begin
		reset <= '1';
		wait for RESET_WND;
		
		reset <= '0';
		wait;
    end process;
	
	-- Stimulus process
	dut_Switches <=	std_logic_vector(to_unsigned(Switches_int,dut_Switches'LENGTH));
	 
	stim_proc: process
	begin
	
		-- waiting the reset wave
		
		Switches_int <= 0 ;
		wait for RESET_WND;
		
		-- start 
		for I in 0 to 2**DUT_NUM_OF_SWS+1 loop
		
			Switches_int <= I ;
			
			wait for  (I+1)*1e6 ns;
		end loop ;
		
	
		-- stop
		wait;
	end process;
end Behavioral;

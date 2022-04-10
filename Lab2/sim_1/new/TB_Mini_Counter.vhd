library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.ALL;

entity TB_Mini_Counter is
--  Port ( );
end TB_Mini_Counter;

architecture Behavioral of TB_Mini_Counter is
	
	---- DUT ----
	component Mini_Counter is
		Generic(
			TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16	:= 4	-- Tail length
		);
		Port ( 
			clk		: 	in 	std_logic;
			reset	: 	in 	std_logic;
			
			din		:	in	std_logic;
			enable	:	in	std_logic;
			dout	:	out	std_logic_vector(integer(log2(real(TAIL_LENGTH))) DOWNTO 0)
		);
	end component;
	
	
	---- CONSTANT DECLARATION ----
	-- Timing
	constant CLKPeriod		 :	Time:= 10 ns;
	
	-- DUT Generics
	constant DUT_TAIL_LENGTH :	Integer := 4;
	
	constant TAIL_BIT		 :	Integer := integer(log2(real(DUT_TAIL_LENGTH)));
	
	--- SIGNALS DECLARATION ---
	signal clk				:	std_logic:='1';
	signal reset			:	std_logic:='0';
	signal dut_din			:	std_logic:='1';
	signal dut_enable		:	std_logic:='1';
	signal dut_dout			:	std_logic_vector(TAIL_BIT DOWNTO 0);
	
begin
	--- DUT ---
	Mini_Counter_INST	:	Mini_Counter
		generic map(
			TAIL_LENGTH => DUT_TAIL_LENGTH
		)
		port map(
			clk		=> clk,
			reset	=> reset,
			din		=> dut_din,
			enable	=> dut_enable,
			dout	=> dut_dout
		);
	
	-- clock
	clk <= not clk after CLKPeriod/2;
	
	-- Stimulus process
	process
	begin
		--start
		dut_enable	<= '1';
		dut_din		<= '1';
		
		for I in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;
		
		dut_din <= '0';
			
		for I in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;	
		
		dut_din <= '1';
		
		wait until rising_edge(clk);
		
		dut_din <= '0';
		
		for I in 0 to 3 loop
			wait until rising_edge(clk);
		end loop;
		
		dut_enable <= '0';
		
		--stop
		wait;

	end process;

end Behavioral;

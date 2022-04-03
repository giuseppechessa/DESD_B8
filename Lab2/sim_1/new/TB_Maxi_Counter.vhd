library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Maxi_Counter is
--  Port ( );
end TB_Maxi_Counter;

architecture Behavioral of TB_Maxi_Counter is

	component Maxi_Counter is
	  Generic(
			Number_Of_Pulses	:	POSITIVE	:= 1e6;
			NUM_OF_SWS			:	INTEGER		RANGE	1 TO 16 := 16	-- Number of input switches
	  );
	  Port (
			clk					:	in	std_logic;
			reset				:	in	std_logic;
			
			Switches			:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
			enable				:	out	std_logic
	  );
	end component;
	
	Constant CLK_PERIOD			: Time	   := 10 ns;
	constant Number_Of_Pulses	: POSITIVE := 2e8;
	constant NUM_OF_SWS			: POSITIVE := 16;
	
	signal clk			:	std_logic:= '1';
	signal reset		:	std_logic:= '0';
	signal Switches		:	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
	signal enable		:	std_logic := '0';
	
	signal Switches_int	:	integer;
	
begin

	Inst_Maxi_Counter	: Maxi_Counter
	generic map(
		Number_Of_Pulses=>Number_Of_Pulses,
		NUM_OF_SWS=>NUM_OF_SWS
	)
	port map(
		clk=>clk,
		reset=>reset,
		
		Switches=>Switches,
		enable=>enable
	);
	
	clk<=not clk after CLK_PERIOD/2;
	Switches<=std_logic_vector(to_unsigned(Switches_int,Switches'LENGTH));
	process
	begin
	Switches_int<=1;
	
	
	wait;
	end process;
end Behavioral;

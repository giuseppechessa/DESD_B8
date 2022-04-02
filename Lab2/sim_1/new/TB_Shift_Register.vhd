library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_Shift_Register is
--  Port ( );
end TB_Shift_Register;

architecture Behavioral of TB_Shift_Register is

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
	
	constant CLK_Period		: Time	:= 10 ns;
	constant NUM_OF_LEDS	: INTEGER := 2;

		signal clk		: std_logic := '1';
		signal reset	: std_logic :='0';
			
		signal enable	: std_logic;
		signal Led_Out	: std_logic_vector(NUM_OF_LEDS-1 DOWNTO 0);
begin

	Inst_SR : Shift_Register
	generic map(
		NUM_OF_LEDS=>NUM_OF_LEDS
	)
	port map(
		clk=>clk,
		reset=>reset,
		enable=>enable,
		Led_Out=>Led_Out
	);

	clk<= not clk after CLK_Period/2;
	process
	begin
	enable<='1';
	
	wait;
	end process;

end Behavioral;

library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.ALL;

entity TB_Mini_Counter is
--  Port ( );
end TB_Mini_Counter;

architecture Behavioral of TB_Mini_Counter is
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
	
	constant TAIL_LENGTH	:	Integer := 4;
	constant CLKPeriod		:	Time:= 10 ns;
	constant TAIL_BIT		:	Integer:=integer(floor(log2(real(TAIL_LENGTH))));
	
	signal clk				:	std_logic:='1';
	signal reset			:	std_logic:='0';
	signal din				:	std_logic:='1';
	signal enable			:	std_logic:='1';
	signal dout				:	std_logic_vector(TAIL_BIT DOWNTO 0);
	
begin
	Mini_Counter_INST	:	Mini_Counter
	generic map(
		TAIL_LENGTH=>TAIL_LENGTH
	)
	port map(
		clk=>clk,
		reset=>reset,
		din=>din,
		enable=>enable,
		dout=>dout
	);
	
	clk<=not clk after CLKPeriod/2;
	process
	begin
		din<='1';
		wait for 40 ns;
		din<='0';
		wait;
	end process;

end Behavioral;

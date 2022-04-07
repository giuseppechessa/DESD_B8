library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.ALL;

entity Mini_Counter is
	Generic(
		TAIL_LENGTH				:	INTEGER	RANGE	1 TO 16	:= 4	-- Tail length
	);
    Port ( 
		clk		: 	in 	std_logic;
        reset	: 	in 	std_logic;
		
		din		:	in	std_logic;
		enable	:	in	std_logic;
		dout	:	out	std_logic_vector(integer(log2(real(TAIL_LENGTH))) DOWNTO 0) --It has to be long only the necessary bits
	);
end Mini_Counter;

architecture Behavioral of Mini_Counter is
	signal	Counter	: unsigned(integer(log2(real(TAIL_LENGTH))) DOWNTO 0):=(Others=>'0'); --Internal Counter
	signal  Sub		: std_logic;
begin
	dout<=std_logic_vector(Counter);
	
	process (clk,reset)
	begin
		if reset='1' then
			Counter<=(Others=>'0');  --asincronous reset
		elsif rising_edge(clk) then
			if din='1' then
				Counter<=to_unsigned(TAIL_LENGTH,Counter'LENGTH); --it goes up to TAIL_LENGTH when it has an input
			elsif din='0' and Counter>0 and Sub='0' then
				Counter<=Counter-1;  -- it decreses until 0 when no input is applied
				Sub<='1';
			end if;
			if enable='1' then  --only in case of enable that is high, so we can simulate a slower clk
                Sub <='0';
			end if;
		end if;
	end process;

end Behavioral;

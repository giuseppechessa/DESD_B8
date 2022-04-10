library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.MATH_REAL.ALL;

entity Mini_Counter is
	Generic(
		TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16	:= 4  -- Tail length
	);
    Port ( 
		clk		: 	in 	std_logic;
        reset	: 	in 	std_logic;
		
		din		:	in	std_logic;
		enable	:	in	std_logic;

		dout	:	out	std_logic_vector(integer(log2(real(TAIL_LENGTH))) DOWNTO 0) --We design dout to have as many bits as we need and no more than that
	);
end Mini_Counter;

architecture Behavioral of Mini_Counter is

	signal	Counter			: unsigned(integer(log2(real(TAIL_LENGTH))) DOWNTO 0) := (Others => '0'); --Internal Counter
	signal  Enable_Sig		: std_logic;

begin

	dout <= std_logic_vector(Counter);
	
	process (clk, reset)
	begin

		if reset = '1' then

			Counter <= (Others => '0');  --Asyncronous reset

		elsif rising_edge(clk) then

			if din = '1' then
				Counter <= to_unsigned(TAIL_LENGTH, Counter'LENGTH); --Counter is set to TAIL_LENGTH when we have din = '1' as input

			elsif din = '0' and Counter > 0 and Enable_Sig = '1' then
				Counter <= Counter - 1;  --Counter is decreased until 0 when no input is applied, one clock cycle after enable is 1: Enable_Sig is necessary to obtain a tail with the right length
				Enable_Sig <= '0';
			end if;

			if enable = '1' then  --This condition makes it so the counter can only be decreased in the clock cycle after enable is set to 1
                Enable_Sig <='1';
			end if;

		end if;

	end process;

end Behavioral;
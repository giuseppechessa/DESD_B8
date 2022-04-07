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
		dout	:	out	std_logic_vector(integer(floor(log2(real(TAIL_LENGTH)))) DOWNTO 0)
	);
end Mini_Counter;

architecture Behavioral of Mini_Counter is
	
	signal	Counter	: unsigned(integer(floor(log2(real(TAIL_LENGTH)))) DOWNTO 0) := (Others=>'0');

begin
	dout<=std_logic_vector(Counter);
	
	process (clk,reset)
	begin
	
		if reset='1' then
			Counter<=(Others=>'0');
			
		elsif rising_edge(clk) then
			if enable='1' then
			
				if din='1' then
					Counter<=to_unsigned(TAIL_LENGTH,Counter'LENGTH);
				elsif din='0' and Counter>0 then
					Counter<=Counter-1;
				end if;
				
			end if;
		end if;
	end process;

end Behavioral;

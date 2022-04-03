library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.ALL;
	
entity Maxi_Counter is
  Generic(
		Number_Of_Pulses	:	POSITIVE	:= 1e6;
		NUM_OF_SWS			:	INTEGER		RANGE	1 TO 16 := 16	-- Number of input switches
  );
  Port (
		clk		:	in	std_logic;
		reset	:	in	std_logic;
		
		Switches	:	in	std_logic_vector(NUM_OF_SWS-1 DOWNTO 0);
		enable	:	out	std_logic
  );
end Maxi_Counter;

architecture Behavioral of Maxi_Counter is
    constant Zero_Value     :unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others=>'0');

	signal PrimaryCounter	:	unsigned(integer(floor(log2(real(Number_Of_Pulses)))) DOWNTO 0):= (Others=>'0');
	signal SecondaryCounter	:	unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others=>'0');
	signal Switches_value	:	unsigned(NUM_OF_SWS-1 DOWNTO 0) := (Others=>'0');
	signal enable_proxy    	:	std_logic := '0';
	
begin
    enable<=enable_proxy;
	process (clk,reset)
	begin
		if reset= '1' then
			enable_proxy<='0';
			PrimaryCounter<= (Others=>'0');
			SecondaryCounter<= (Others=>'0');
			Switches_value<=unsigned(Switches);
		elsif rising_edge(clk) then
			enable_proxy<='0';
			PrimaryCounter<=PrimaryCounter+1;
			if PrimaryCounter>=to_unsigned(Number_Of_Pulses,PrimaryCounter'LENGTH) then
				PrimaryCounter<= (Others=>'0');
				SecondaryCounter<=SecondaryCounter+1;
				if SecondaryCounter>=unsigned(Switches_value) then
					SecondaryCounter<= (Others=>'0');
					enable_proxy<='1';
				end if;
			end if;
			if SecondaryCounter=Zero_Value then
				Switches_value<=unsigned(Switches);
			end if;
		end if;
	end process;


end Behavioral;

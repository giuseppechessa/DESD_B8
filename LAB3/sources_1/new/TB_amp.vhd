library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity TB_amp is
--  Port ( );
end TB_amp;

architecture Behavioral of TB_amp is
	component amp_generator is
		Generic(
			jstk_units : integer range 5 TO 10 := 5
		);
		Port (
			aclk     : in std_logic;
			aresetn     : in std_logic;
			
			volume : in std_logic_vector(9 DOWNTO 0);
			
			amp_power : out std_logic_vector(9-jstk_units DOWNTO 0);
			amp_sign : out std_logic
		);
	end component;
	
	constant CLK_PERIOD	:	Time:= 10ns;
	constant JSTK_UNITS	:	Integer:=6;
	
	signal clk			:	std_logic :='0';
	signal aresetn		:	std_logic :='1';
	
	signal volume 		:	std_logic_vector (9 downto 0);
	
	signal amp_power	:	std_logic_vector(9-jstk_units DOWNTO 0);
	signal amp_sign		:	std_logic;
	
	signal volume_int	:	Integer:=0;

begin

	INST_AMP : amp_generator
	generic map(
		jstk_units=>JSTK_UNITS
	)
	port map(
		aclk=>clk,
		aresetn=>aresetn,
		volume=>volume,
		amp_power=>amp_power,
		amp_sign=>amp_sign
	);
	
	clk<= not clk after CLK_PERIOD;
	volume<=std_logic_vector(to_unsigned(volume_int,volume'LENGTH));
	
	process
	begin
	for I in 0 to 1024 loop
	   volume_int <= I;
	   wait until rising_edge(clk);
	   wait until rising_edge(clk);
	   wait until rising_edge(clk);
	   wait until rising_edge(clk);
	end loop;
	wait;
	end process;

end Behavioral;
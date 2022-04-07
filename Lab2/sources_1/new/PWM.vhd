library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;

entity PWM is
  GENERIC(
  
    BIT_LENGTH  : INTEGER RANGE 1 TO 16 := 8;	-- Bit used  inside PWM

    T_ON_INIT   : POSITIVE := 64;				-- Init of Ton
    PERIOD_INIT : POSITIVE := 128;				-- Init of Period

    PWM_INIT    : std_logic:='1'				-- Init of PWM
  );
  Port (
	
    reset : in  std_logic;
    clk   : in  std_logic;
	
	
    Ton   : in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0) := std_logic_vector(to_unsigned(T_ON_INIT,BIT_LENGTH)); 	-- clk at PWM = '1'
    Period: in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0) := std_logic_vector(to_unsigned(PERIOD_INIT,BIT_LENGTH));	-- clk per period of PWM

    PWM   : out std_logic 								:= PWM_INIT			-- PWM signal
  );
end PWM;

architecture Behavioral of PWM is

	signal Ton_new      : unsigned(BIT_LENGTH-1 DOWNTO 0) := (Others=>'0');
	
	-- signal used to count the number of clock cycles elapsed 
	signal Time_elapsed : unsigned(BIT_LENGTH-1 DOWNTO 0) := (Others=>'0');

  
begin

	process (clk,reset)
	begin
		-- Reset
		if reset ='1' then
			PWM			<= PWM_INIT;
			Ton_new		<= (Others=>'0');
			Time_elapsed<= (Others=>'0');
		  
		elsif  rising_edge(clk) then
			
			-- Count the clock pulses
		    Time_elapsed <= Time_elapsed + 1;
		 
			-- When the counter reaches the period value we reset the counter and sample the Ton 
		    if(Time_elapsed >= unsigned(Period)) then
		  
				Time_elapsed <=( Others=>'0');	 
				Ton_new		 <= unsigned(Ton);			
			
		    end if;
		  
			
		    if(Time_elapsed < Ton_new) then		-- clk cycles at PWM = '1' 		
				PWM<=PWM_INIT;
		    elsif(Time_elapsed >= Ton_new) then   -- clk cycles at PWM = '0'
				PWM<=not PWM_INIT;
		    end if;
		  
		  
		end if;
	end process;


end Behavioral;

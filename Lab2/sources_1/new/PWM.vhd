library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;

entity PWM is
  GENERIC(
    BIT_LENGTH : INTEGER RANGE 1 TO 16 := 8;

    T_ON_INIT  : POSITIVE :=64;
    PERIOD_INIT : POSITIVE := 128;

    PWM_INIT    : std_logic:='0'
  );
  Port (
    reset : in  std_logic;
    clk   : in  std_logic;

    Ton   : in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0):=std_logic_vector(to_unsigned(T_ON_INIT,BIT_LENGTH));
    Period: in  std_logic_vector(BIT_LENGTH-1 DOWNTO 0):=std_logic_vector(to_unsigned(PERIOD_INIT,BIT_LENGTH));

    PWM   : out std_logic:=PWM_INIT
   );
end PWM;

architecture Behavioral of PWM is
  signal Time_elapsed : unsigned(BIT_LENGTH-1 DOWNTO 0);
  signal Ton_new     : unsigned(BIT_LENGTH-1 DOWNTO 0);
begin

  process (clk,reset)
  begin
    if reset ='1' then
      PWM<='0';
      Ton_new<=(Others=>'0');
      Time_elapsed<=(Others=>'0');
    elsif  rising_edge(clk) then
      Time_elapsed<=Time_elapsed+1;
      if(Time_elapsed>= unsigned(Period)) then
        Time_elapsed<=(Others=>'0');
        Ton_new<=unsigned(Ton);
      end if;
      if(Time_elapsed<Ton_new) then
        PWM<=PWM_INIT;
      elsif(Time_elapsed>=Ton_new) then
        PWM<=not PWM_INIT;
      end if;
    end if;
  end process;


end Behavioral;

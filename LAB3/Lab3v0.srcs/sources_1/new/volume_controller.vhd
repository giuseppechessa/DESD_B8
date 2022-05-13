library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity volume_controller is
  Generic(
        jstk_units : integer range 1 TO 10 := 6
  );
  Port (
        
        areset : in std_logic;
        aclk : in std_logic;
        
        volume : in std_logic_vector(9 DOWNTO 0);
        
        s_axis_tdata : in std_logic_vector(7 DOWNTO 0);
        s_axis_tvalid : in std_logic;
        s_axis_tlast : in std_logic;
        s_axis_tready : out std_logic;
        
        m_axis_tdata : out std_logic_vector(7 DOWNTO 0);
        m_axis_tvalid : out std_logic;
        m_axis_tlast : out std_logic;
        m_axis_tready : in std_logic
  
  );
end volume_controller;

architecture Behavioral of volume_controller is
    
--    signal shifter : std_logic_vector(jstk_units DOWNTO 0) := (Others => '0');
    
    constant offset_sig : signed(10-1 DOWNTO 0) := to_signed(2**(jstk_units - 1), 10 );
    constant offset : signed(10-1 DOWNTO 0) := to_signed((1024 / 2**(jstk_units + 1)) - 1, 10);
    
    signal shifter : signed(10 DOWNTO 0) := (Others => '0');
    
    signal volume_aux : signed(24+jstk_units - 1 DOWNTO 0) := (Others => '0');
begin
    
    process(aclk, areset)
    begin
    
        if areset = '1' then
            
        elsif rising_edge(aclk) then
            
            volume_aux(24-2 DOWNTO 0) <= signed(volume(22 DOWNTO 0));
            volume_aux(volume_aux'HIGH) <= volume(volume'HIGH);
            
            shifter <= 
        end if;
    
    end process;

end Behavioral;
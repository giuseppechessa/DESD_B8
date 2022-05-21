library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.MATH_REAL.ALL;

entity signal_amplification is
	Generic(
		BALANCE : Integer :=0;
		MUSIC_DEPTH	:	Integer:=24;
		AMPL_DEPTH	:	Integer:=4
	);
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        din_left : in std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0);
        din_right : in std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0);
        
        amp_power : in std_logic_vector(AMPL_DEPTH downto 0);
        amp_sign : in std_logic;
        
        balance_check : in std_logic;
        
        dout_left : out std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0);
        dout_right : out std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0)
    );
end signal_amplification;

architecture Behavioral of signal_amplification is
	constant	ShiterZeroDepth 	: Integer :=integer(2**real(AMPL_DEPTH));
    
    signal shifter_dx : std_logic_vector(ShiterZeroDepth -1 DOWNTO 0);
	signal shifter_sx : std_logic_vector(ShiterZeroDepth-1 DOWNTO 0);
    
    signal zeros : std_logic_vector(ShiterZeroDepth-1 DOWNTO 0);
    
begin
	VOLUME_MODE: if BALANCE = 0 generate
		process(aclk, aresetn)
		begin
			if rising_edge(aclk) then
			
				if aresetn = '0' then
					dout_left <= (Others => '0');
					dout_right <= (Others => '0');
					
				else
					if amp_sign = '1' then
						shifter_dx <= (Others => din_right(dout_right'HIGH));--Stadio1
						--dout_right <= shifter_dx(to_integer(unsigned(amp_power))-1 DOWNTO 0) & din_right(dout_right'HIGH DOWNTO to_integer(unsigned(amp_power)));
						dout_right(dout_right'HIGH-to_integer(unsigned(amp_power))-1 DOWNTO 0)<= din_right(din_right'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));--Stadio1
						dout_right(dout_right'HIGH DOWNTO to_integer(unsigned(amp_power))) <= shifter_dx(to_integer(unsigned(amp_power))-1 DOWNTO 0);--Stadio2
						shifter_sx <= (Others => din_left(din_left'HIGH));
						--dout_left <= shifter_sx(to_integer(unsigned(amp_power))-1 DOWNTO 0) & din_left(to_integer(unsigned(amp_power))'HIGH DOWNTO amp_power);
						dout_left(dout_left'HIGH-to_integer(unsigned(amp_power))-1 DOWNTO 0)<= din_left(din_left'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));
						dout_left(dout_left'HIGH DOWNTO to_integer(unsigned(amp_power))) <= shifter_sx(to_integer(unsigned(amp_power))-1 DOWNTO 0);
					-- If the amplification power is positive...
					elsif amp_sign = '0' then
						-- For both channels, whatever the sign of the signal, when we shift leftwards we'll need to add 1 or multiple '0' to the LSBs
						zeros <= (Others => '0');
						
						-- If the channnel won't saturate we may just shift leftwards the signal
						shifter_sx <= (Others => din_left(din_left'HIGH));
						if din_left(din_left'HIGH DOWNTO din_left'HIGH-to_integer(unsigned(amp_power))) = shifter_sx(to_integer(unsigned(amp_power))-1 DOWNTO 0) then
							dout_left <= din_left(din_left'HIGH-to_integer(unsigned(amp_power)) DOWNTO 0) & zeros(to_integer(unsigned(amp_power))-1 DOWNTO 0);
						else
							-- If the channel does saturate we'll need to assign the highest possible value, whatever the sign of the signal
							dout_left <= (dout_left'HIGH => din_left(din_left'HIGH), Others => not din_left(din_left'HIGH));
						end if;
						
						shifter_dx <= (Others => din_right(dout_right'HIGH));
						if din_right(din_right'HIGH DOWNTO din_right'HIGH-to_integer(unsigned(amp_power))) = shifter_dx(to_integer(unsigned(amp_power))-1 DOWNTO 0) then
							dout_right <= din_right(din_right'HIGH-to_integer(unsigned(amp_power)) DOWNTO 0) & zeros(to_integer(unsigned(amp_power))-1 DOWNTO 0);
						else
							dout_right <= (dout_right'HIGH => din_right(din_right'HIGH), Others => not din_left(din_right'HIGH));
						end if;
					end if;
				end if;
			end if;
		end process;
	end generate;
	
	BALANCE_MODE: if BALANCE = 1 generate
		process(aclk, aresetn)
		begin
		
			if rising_edge(aclk) then
			
				if aresetn = '0' then
					dout_left <= (Others => '0');
					dout_right <= (Others => '0');
					
				else
					-- If the amplification power is negative we'll always lower the volume of the right channel
					if amp_sign = '1' then
					
						shifter_dx <= (Others => din_right(din_right'HIGH));--Stadio1
--                        dout_right <= shifter_dx(amp_power-1 DOWNTO 0) & din_right(dout_right'HIGH DOWNTO amp_power);
						dout_right(dout_right'HIGH-1-to_integer(unsigned(amp_power)) DOWNTO 0)<= din_right(din_right'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));--Stadio1
						dout_right(dout_right'HIGH DOWNTO to_integer(unsigned(amp_power))) <= shifter_dx(to_integer(unsigned(amp_power))-1 DOWNTO 0);--Stadio2
						dout_left <= din_left;
					elsif amp_sign = '0' then
						shifter_sx <= (Others => din_left(din_left'HIGH));
--                            dout_left <= shifter_sx(to_integer(unsigned(amp_power))-1 DOWNTO 0) & din_left(din_left'HIGH DOWNTO to_integer(unsigned(amp_power)));
						dout_left(dout_left'HIGH-1-to_integer(unsigned(amp_power)) DOWNTO 0)<= din_left(din_left'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));
						dout_left(dout_left'HIGH DOWNTO to_integer(unsigned(amp_power))) <= shifter_sx(to_integer(unsigned(amp_power))-1 DOWNTO 0);
						dout_right <= din_right;
					end if;
				end if;
			end if;
		end process;
	end generate;
    

end Behavioral;
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.MATH_REAL.ALL;

entity signal_amplification is
	Generic(
		BALANCE_ACTIVE	:	Integer range 0 to 1:=0;
		DX_ACTIVE		:	Integer range 0 to 1:=0;
		MUSIC_DEPTH		:	Integer:=24;
		AMPL_DEPTH		:	Integer:=5
	);
    Port (
        aclk     : in std_logic;
        aresetn     : in std_logic;
        
        din : in std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0);
        
        amp_power : in std_logic_vector(AMPL_DEPTH-1 downto 0);
        amp_sign : in std_logic;
        
        dout : out std_logic_vector(MUSIC_DEPTH-1 DOWNTO 0)
    );
end signal_amplification;

architecture Behavioral of signal_amplification is
	constant	ShiterZeroDepth 	: Integer :=integer(2**real(AMPL_DEPTH-1));
	constant	DX_ACTIVE_STD	:	std_logic_vector:= std_logic_vector(to_unsigned(DX_ACTIVE,1));
    
    signal shifter : std_logic_vector(ShiterZeroDepth DOWNTO 0);
    signal zeros : std_logic_vector(ShiterZeroDepth DOWNTO 0);
    
begin
	VOLUME_MODE: if BALANCE_ACTIVE = 0 generate
		process(aclk, aresetn)
		begin
			if rising_edge(aclk) then
				if aresetn = '0' then
					dout <= (Others => '0');
				else
					if amp_sign = '1' then
						shifter <= (Others => din(din'HIGH));--Stadio1
						dout(dout'HIGH-to_integer(unsigned(amp_power))-1 DOWNTO 0)<= din(din'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));--Stadio1
						dout(dout'HIGH DOWNTO dout'HIGH-to_integer(unsigned(amp_power))) <= shifter(to_integer(unsigned(amp_power)) DOWNTO 0);--Stadio2
					elsif amp_sign = '0' then
						-- For both channels, whatever the sign of the signal, when we shift leftwards we'll need to add 1 or multiple '0' to the LSBs
						zeros <= (Others => '0');
						shifter <= (Others => din(din'HIGH));
						if din(din'HIGH downto din'HIGH-to_integer(unsigned(amp_power))) = shifter(to_integer(unsigned(amp_power)) downto 0) then
							dout <= din(din'HIGH-to_integer(unsigned(amp_power)) DOWNTO 0) & zeros(to_integer(unsigned(amp_power))-1 DOWNTO 0);
						else
							dout <= (dout'HIGH => din(din'HIGH), Others => not din(din'HIGH));
						end if;
					end if;
				end if;
			end if;
		end process;
	end generate;
	
	BALANCE_MODE: if BALANCE_ACTIVE = 1 generate
		process(aclk, aresetn)
		begin
			if rising_edge(aclk) then
			
				if aresetn = '0' then
					dout <= (Others => '0');
				else
					-- If the amplification power is negative we'll always lower the volume of the right channel
					if amp_sign = DX_ACTIVE_STD(0) then
					
						shifter <= (Others => din(din'HIGH));--Stadio1
--                        dout_right <= shifter_dx(amp_power-1 DOWNTO 0) & din(dout_right'HIGH DOWNTO amp_power);
						dout(dout'HIGH-1-to_integer(unsigned(amp_power)) DOWNTO 0)<= din(din'HIGH-1 DOWNTO to_integer(unsigned(amp_power)));--Stadio1
						dout(dout'HIGH DOWNTO dout'HIGH-to_integer(unsigned(amp_power))) <= shifter(to_integer(unsigned(amp_power)) DOWNTO 0);--Stadio2
					elsif amp_sign = not DX_ACTIVE_STD(0) then
						dout <= din;
					end if;
				end if;
			end if;
		end process;
	end generate;
    

end Behavioral;
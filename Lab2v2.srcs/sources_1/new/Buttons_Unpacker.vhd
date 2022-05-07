library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Buttons_Unpacker is
	Port ( 
		aclk 			: in  STD_LOGIC;
		aresetn			: in  STD_LOGIC;

		-- Data coming FROM the SPI IP-Core (and so, from the JSTK2 module)
		-- There is no tready signal, so you must be always ready to accept and use the incoming data, or it will be lost!
		s_axis_tvalid	: in STD_LOGIC;
		s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);

		-- Joystick and button values read from the module
		jstk_x			: out std_logic_vector(9 downto 0);
		jstk_y			: out std_logic_vector(9 downto 0);
		btn_jstk		: out std_logic;
		btn_trigger		: out std_logic
	);
end Buttons_Unpacker;

architecture Behavioral of Buttons_Unpacker is

	type state_sts_type is (GET_X_LSB, GET_X_MSB, GET_Y_LSB, GET_Y_MSB, GET_BUTTONS);
	signal state_sts			: state_sts_type := GET_X_LSB;
	signal jstk_temp	:	std_logic_vector(7 downto 0);
	alias	jstkx_LOW	:	std_logic_vector(7 downto 0)	is	jstk_x(7 downto 0);
	alias	jstkx_HIGH	:	std_logic_vector(1 downto 0)	is	jstk_x(9 downto 8);
	alias	jstky_LOW	:	std_logic_vector(7 downto 0)	is	jstk_y(7 downto 0);
	alias	jstky_HIGH	:	std_logic_vector(1 downto 0)	is	jstk_y(9 downto 8);
	

begin
    
    process(aclk, aresetn)
    begin
        
        if rising_edge(aclk) then
        
            if aresetn = '0' then
                state_sts <= GET_X_LSB;
                
            else
            
                case state_sts is
                
                    when GET_X_LSB =>
                        if s_axis_tvalid = '1' then
                            jstk_temp <= s_axis_tdata;
                            state_sts <= GET_X_MSB;
                        end if;
                        
                    when GET_X_MSB =>
                        if s_axis_tvalid = '1' then
							jstkx_LOW <= jstk_temp;
                            jstkx_HIGH <= s_axis_tdata(1 DOWNTO 0);
                            state_sts <= GET_Y_LSB;
                        end if;
                        
                    when GET_Y_LSB =>
                        if s_axis_tvalid = '1' then
                            jstk_temp <= s_axis_tdata;
                            state_sts <= GET_Y_MSB;
                        end if;
                    
                    when GET_Y_MSB =>
                        if s_axis_tvalid = '1' then
							jstky_LOW <= jstk_temp;
                            jstky_HIGH <= s_axis_tdata(1 DOWNTO 0);
                            state_sts <= GET_BUTTONS;
                        end if;
                        
                    when GET_BUTTONS =>
                        if s_axis_tvalid = '1' then
                            btn_trigger <= s_axis_tdata(1);
                            btn_jstk <= s_axis_tdata(0);
                            state_sts <= GET_X_LSB;
                        end if;
                        
                end case;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
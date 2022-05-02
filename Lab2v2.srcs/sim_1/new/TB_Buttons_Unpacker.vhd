library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_Buttons_Unpacker is
--  Port ( );
end TB_Buttons_Unpacker;

architecture Behavioral of TB_Buttons_Unpacker is

    component Buttons_Unpacker is
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;
            
            s_axis_tvalid	: in STD_LOGIC;
            s_axis_tdata	: in STD_LOGIC_VECTOR(7 downto 0);

            jstk_x			: out std_logic_vector(11 downto 0);
            jstk_y			: out std_logic_vector(11 downto 0);
            btn_jstk		: out std_logic;
            btn_trigger		: out std_logic
        );
    end component;
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	constant HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0";
	
    signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
		
	signal s_axis_tvalid	: STD_LOGIC;
    signal s_axis_tdata	: STD_LOGIC_VECTOR(7 downto 0);
    
    signal jstk_x			: std_logic_vector(11 downto 0);
    signal jstk_y			: std_logic_vector(11 downto 0);
    signal btn_jstk		:	std_logic;
    signal btn_trigger		:	std_logic;
    
begin

    BUTTONS_UNPACKER_INST : Buttons_Unpacker
        Port Map(
            aclk => aclk,
            aresetn	=> aresetn,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tdata => s_axis_tdata,
            jstk_x => jstk_x,	
            jstk_y => jstk_y,
            btn_jstk => btn_jstk,
            btn_trigger => btn_trigger
        );
        
    aclk	<=	not aclk after CLK_PERIOD/2;
	
	-- Reset Process 
	reset_wave :process
	begin
		aresetn <= '0';
		wait for RESET_WND;
		
		aresetn <= '1';
		wait;
    end process;
    
    process
    begin
        
        wait for RESET_WND;
        
        wait for 1000ns;
        s_axis_tvalid <= '1';
        s_axis_tdata <= "10011001";
        wait for CLK_PERIOD;
        s_axis_tdata <= "01111110";
        wait for CLK_PERIOD;
        s_axis_tdata <= "10101010";    
        wait for CLK_PERIOD;
        s_axis_tdata <= "10001010";
        wait for CLK_PERIOD;
        s_axis_tdata <= "00101011";
        wait for CLK_PERIOD;
        
        s_axis_tdata <= "01101100";
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD*20;
        s_axis_tvalid <= '1';
        wait;
        
    end process;
    
end Behavioral;

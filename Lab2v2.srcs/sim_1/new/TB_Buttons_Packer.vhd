library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Buttons_Packer is
--  Port ( );
end TB_Buttons_Packer;

architecture Behavioral of TB_Buttons_Packer is

    component Buttons_Packer is
        generic (
            HEADER_CODE		: std_logic_vector(7 downto 0);
            TX_DELAY		: positive := 1000000;
            JSTK_BITS		: integer range 1 to 7 := 7
        );
        Port ( 
            aclk 			: in  STD_LOGIC;
            aresetn			: in  STD_LOGIC;
    
            jstk_x			: in std_logic_vector(11 downto 0);
            jstk_y			: in std_logic_vector(11 downto 0);
            btn_jstk		: in std_logic;
            btn_trigger		: in std_logic;

            m_axis_tready	: in STD_LOGIC;
            m_axis_tvalid	: out STD_LOGIC;
            m_axis_tdata	: out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
  
    
    constant CLK_PERIOD		: Time	:= 10 ns;
	constant RESET_WND		: Time	:= 10*CLK_PERIOD;
	
	constant HEADER_CODE		: std_logic_vector(7 downto 0) := x"c0";
	constant TX_DELAY		: positive := 1000000;    -- Pause (in clock cycles) between two packets
	constant JSTK_BITS		: integer range 1 to 7 := 7;
	
    signal aclk			:	std_logic:= '1';
	signal aresetn		:	std_logic:= '1';
	
	signal m_axis_tvalid	: STD_LOGIC;
    signal m_axis_tdata	    : STD_LOGIC_VECTOR(7 downto 0);
    signal m_axis_tready	: STD_LOGIC;
    
    signal jstk_x			: std_logic_vector(11 downto 0);
    signal jstk_y			: std_logic_vector(11 downto 0);
    signal btn_jstk		    :	std_logic;
    signal btn_trigger		:	std_logic;
    
begin

    BUTTONS_PACKER_INST : Buttons_Packer
    Generic Map(
        HEADER_CODE => HEADER_CODE,
        TX_DELAY => TX_DELAY,
        JSTK_BITS => JSTK_BITS
    )
    Port Map(
        aclk => aclk,
        aresetn	=> aresetn,
        jstk_x => jstk_x,
        jstk_y => jstk_y,
        btn_jstk => btn_jstk,
        btn_trigger => btn_trigger,
        m_axis_tready => m_axis_tready,
        m_axis_tvalid => m_axis_tvalid,
        m_axis_tdata => m_axis_tdata
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
        m_axis_tready <= '1';
        jstk_x <= "101010101010";
        jstk_y <= "010101010101";
        btn_jstk <= '0';
        btn_trigger <= '1';
        wait for 15ms;
        
        m_axis_tready <= '0';
        
        jstk_x <= "010101010101";
        jstk_y <= "101010101010";
        btn_jstk <= '1';
        btn_trigger <= '0';
        wait for 10ms;
        m_axis_tready <= '1';
        wait;
    end process;
end Behavioral;

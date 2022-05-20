library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;


entity AXISTREAM_TEMPLATE is
	Generic(
		boh_cose_varie	: Integer
	);
  Port ( 
	aclk			:	in	std_logic;
	aresetn			:	in	std_logic;
	
	s_axis_tdata    :	in	std_logic_vector(24-1 DOWNTO 0);
    s_axis_tvalid   :	in	std_logic;
    s_axis_tlast    :	in	std_logic;
    s_axis_tready   :	out	std_logic;
	
	m_axis_tdata    :	out	std_logic_vector(24-1 DOWNTO 0);
    m_axis_tvalid   :	out	std_logic;
    m_axis_tlast    :	out	std_logic;
    m_axis_tready   :	in	std_logic
  
  
  );
end AXISTREAM_TEMPLATE;

architecture Behavioral of AXISTREAM_TEMPLATE is
	 constant Pipeline_legth  : signed(4 DOWNTO 0) := "0100";
	
	type	RxAxis_t	is (IDLE,Rx_READY,Elaboration_sx,Elaboration_dx);
	signal	RxAxis	:	RxAxis_t:=IDLE;
	
	type	TxAxis_t	is (IDLE,Tx);
	signal	TxAxis	:	TxAxis_t:=IDLE;
	
	signal	s_axis_tready_AUX	:	std_logic;
	signal	m_axis_tvalid_AUX	:	std_logic;
    signal	m_axis_tlast_AUX	:	std_logic;
	
	signal	Audio_sx_in	:	signed(24-1 DOWNTO 0);
	signal	Audio_dx_in	:	signed(24-1 DOWNTO 0);
	
	signal	Audio_sx_out	:	signed(24-1 DOWNTO 0);
	signal	Audio_dx_out	:	signed(24-1 DOWNTO 0);
	
	signal Counter_Pipeline	:	signed(4 downto 0):= Pipeline_legth;
	signal Combinatorial_Finished	:	std_logic;
begin

	m_axis_tlast<=m_axis_tlast_AUX;
	m_axis_tvalid<=m_axis_tvalid_AUX;
	s_axis_tready<=s_axis_tready_AUX;

	RxProcess : process (aclk)
	begin
	if rising_edge(aclk) then
		if aresetn='0' then
			RxAxis<=IDLE;
		else
			case (RxAxis) is
				when IDLE=>
					Counter_Pipeline<= Pipeline_legth;
					Combinatorial_Finished<='0';
					s_axis_tready_AUX<='1';
					RxAxis<=Rx_READY;
				when Rx_READY=>
					if s_axis_tvalid='1' and s_axis_tready_AUX='1' then
						if s_axis_tlast='1' then
							RxAxis<=Elaboration_dx;
							Audio_sx_in<=signed(s_axis_tdata);
						else 
							RxAxis<=Elaboration_sx;
							Audio_dx_in<=signed(s_axis_tdata);
						end if;
						s_axis_tready_AUX<='0';
					end if;
				when Elaboration_sx=>
					Counter_Pipeline<=Counter_Pipeline-1;
					if Counter_Pipeline=(Others=>'0') then 
						RxAxis<=IDLE;
						Combinatorial_Finished<='1';
						m_axis_tlast_AUX<='0';
					end if;
				when Elaboration_dx=>
					Counter_Pipeline<=Counter_Pipeline-1;
					if Counter_Pipeline=(Others=>'0') then 
						RxAxis<=IDLE;
						Combinatorial_Finished<='1';
						m_axis_tlast_AUX<='1';
					end if;
				when Others=>
					RxAxis<=IDLE;
			end case;
		end if;
	end if;
	end process;
	
	TxProcess : process (aclk)
	begin
	if rising_edge(aclk) then
		if aresetn='0' then
			TxAxis<=IDLE;
		else
			case (TxAxis) is
				when IDLE=>
					if Combinatorial_Finished='1' then 
						if m_axis_tlast_AUX='1' then 
							m_axis_tdata<=std_logic_vector(Audio_dx_out);
						elsif m_axis_tlast_AUX='0' then
							m_axis_tdata<=std_logic_vector(Audio_sx_out);
						end if;
						TxAxis<=Tx;
						m_axis_tvalid_AUX<='1';
					end if;
				when Tx=>
					if m_axis_tvalid_AUX='1' and m_axis_tready='1' then
						m_axis_tvalid_AUX<='0';
						TxAxis<=IDLE;
					end if;
				when Others=>
					TxAxis<=IDLE;
			end case;
		end if;
	end if;
	end process;


end Behavioral;

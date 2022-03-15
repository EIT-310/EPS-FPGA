-- Copyright (C) 2021  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE0_CV_golden_top is
	port
	(
		CLOCK2_50 : in std_logic;
		CLOCK3_50 : in std_logic;
		CLOCK4_50 : in std_logic;
		CLOCK_50 : in std_logic;
		DRAM_CAS_N : in std_logic;
		DRAM_CKE : in std_logic;
		DRAM_CLK : in std_logic;
		DRAM_CS_N : in std_logic;
		DRAM_LDQM : in std_logic;
		DRAM_RAS_N : in std_logic;
		DRAM_UDQM : in std_logic;
		DRAM_WE_N : in std_logic;
		PS2_CLK : in std_logic;
		PS2_CLK2 : in std_logic;
		PS2_DAT : in std_logic;
		PS2_DAT2 : in std_logic;
		RESET_N : in std_logic;
		SD_CLK : in std_logic;
		SD_CMD : in std_logic;
		VGA_HS : in std_logic;
		VGA_VS : in std_logic;
		DRAM_ADDR : in std_logic_vector(0 to 12);
		DRAM_BA : in std_logic_vector(0 to 1);
		DRAM_DQ : in std_logic_vector(0 to 15);
		GPIO_0 : in std_logic_vector(0 to 35);
		GPIO_1 : out std_logic_vector(0 to 35);
		HEX0 : out std_logic_vector(0 to 6);
		HEX1 : in std_logic_vector(0 to 6);
		HEX2 : in std_logic_vector(0 to 6);
		HEX3 : in std_logic_vector(0 to 6);
		HEX4 : in std_logic_vector(0 to 6);
		HEX5 : in std_logic_vector(0 to 6);
		KEY : in std_logic_vector(0 to 3);
		LEDR : out std_logic_vector(0 to 9);
		SD_DATA : in std_logic_vector(0 to 3);
		SW : in std_logic_vector(0 to 9);
		VGA_B : in std_logic_vector(0 to 3);
		VGA_G : in std_logic_vector(0 to 3);
		VGA_R : in std_logic_vector(0 to 3)
	);

end DE0_CV_golden_top;

architecture ppl_type of DE0_CV_golden_top is
	type byte_arr is array (7 downto 0) of std_logic_vector (7 downto 0);
	
	signal dataa_arr: byte_arr;
	signal rotate 	: std_logic_vector(7 downto 0) := "01000000";
	signal clk 		: std_logic;
	signal add_sub_sig : std_logic;
	signal sel_sig 	: std_logic_vector(2 downto 0);
	signal clockscale	: unsigned(25 downto 0);
	signal result_sig	: std_logic_vector(7 downto 0);
	

	component adder is
		port (
		  clock : in std_logic;
		  add_sub : in std_logic;
		  dataa : in std_logic_vector (7 downto 0);
		  datab : in std_logic_vector (7 downto 0);
		  result: out std_logic_vector ( 7 downto 0)
		) ;
	end component;

	component multiplexer IS
		PORT
		(
			data0x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data1x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data2x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data3x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data4x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data5x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data6x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data7x		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			sel			 : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	end component;

begin

	add_sub_sig <= GPIO_0(0);
	dataa_arr(0)<= "10000000";
	clk 		<= clockscale(25);
	HEX0 		<= (others => clk);
	GPIO_1(35)	<= clk;

	display : for i in 0 to 7 generate
		LEDR(i) <= dataa_arr(7)(i);
	end generate ; -- display

	GPIO_write : for i in 0 to 7 generate
		GPIO_1(i) <= result_sig(7-i);
	end generate ; -- GPIO_write 

	clockscaler : process( CLOCK2_50 )
	begin
		if rising_edge(CLOCK2_50) then
			clockscale <= clockscale + 1 ;
		end if ;
	end process ; -- clockscaler

	rotator : process( clk )
	begin
		if rising_edge(clk) then
			rotate <= rotate(0) & rotate(7 downto 1);

			case( rotate ) is
				
				when "10000000" => sel_sig <= "000";
				when "01000000" => sel_sig <= "000";
				when "00100000" => sel_sig <= "001";
				when "00010000" => sel_sig <= "010";
				when "00001000" => sel_sig <= "011";
				when "00000100" => sel_sig <= "100";
				when "00000010" => sel_sig <= "101";
				when "00000001" => sel_sig <= "110";
			
				when others 	=> sel_sig <= "000";
			
			end case ;

		end if ;
	end process ; -- rotator

	adder_loop : for i in 0 to 6 generate
		adder_inst : adder port map (
			clock => rotate(6-i),
			add_sub => add_sub_sig,
			dataa => dataa_arr(i),
			datab => rotate,
			result => dataa_arr(i+1)
		);
	end generate ; -- adder_loop
	
	multiplexer_inst : multiplexer PORT MAP (
		data0x	=> dataa_arr(0),
		data1x	=> dataa_arr(1),
		data2x	=> dataa_arr(2),
		data3x	=> dataa_arr(3),
		data4x	=> dataa_arr(4),
		data5x	=> dataa_arr(5),
		data6x	=> dataa_arr(6),
		data7x	=> dataa_arr(7),
		sel		=> sel_sig,
		result	=> result_sig
	);

end;

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
		CLOCK2_50 	: in std_logic;
		GPIO_0		: in std_logic_vector(35 downto 0);
		GPIO_1 		: out std_logic_vector(35 downto 0);
		KEY 		: in std_logic_vector(3 downto 0);
		LEDR 		: out std_logic_vector(9 downto 0);
		SW 			: in std_logic_vector(9 downto 0)
	);

end DE0_CV_golden_top;

architecture top of DE0_CV_golden_top is

	signal cluck : unsigned(25 downto 0);

	component MPPT is
        port
        (
        	ADC_Volt_out: out std_logic_vector(7 downto 0);
        	ADC_Curr_out: out std_logic_vector(7 downto 0);
        	PWM_out: out std_logic;
        	main_clk: in std_logic;
        	add_sub_sig: in std_logic_vector(1 downto 0);
			led: out std_logic_vector(8 downto 0)
        );
        end component;
begin

	EPS_MPPT1: MPPT port map (
		ADC_Volt_out	=>	GPIO_1 (7 downto 0),
		ADC_Curr_out	=>	GPIO_1 (17 downto 10),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		PWM_out			=>  LEDR(9),
		main_clk		=>	CLOCK2_50,
		led(8 downto 0) => LEDR(8 downto 0)
	);

	clockscaler1 : process( CLOCK2_50 )
	begin
		if rising_edge(CLOCK2_50) then
			cluck <= cluck + 1 ;
		end if ;
	end process ; -- clockscaler1

end;
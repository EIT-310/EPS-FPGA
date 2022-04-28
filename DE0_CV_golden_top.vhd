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
use ieee.std_logic_unsigned.all;

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

	signal PWM_mes : std_logic;
	component MPPT is
        port
        (
        	ADC_Volt_out 	: out std_logic_vector(7 downto 0);
        	ADC_Curr_out 	: out std_logic_vector(7 downto 0);
			add_sub_sig	 	: in std_logic_vector(1 downto 0);
			main_clk		: in std_logic;
        	PWM_out			: out std_logic
        );
        end component;
begin

	EPS_MPPT1: MPPT port map (
		ADC_Volt_out(7 downto 0)	=>	GPIO_1(7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	GPIO_1(17 downto 10),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  PWM_mes
	);

	GPIO_1(33) <= PWM_mes;
	GPIO_1(32) <= PWM_mes;
end;
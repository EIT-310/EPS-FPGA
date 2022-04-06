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

	signal cluck 	: unsigned (25 downto 0);
	signal R2R_volt : std_logic_vector (7 downto 0);
	signal R2R_curr : std_logic_vector (7 downto 0);
	signal scaler 	: unsigned (12 downto 0);
	signal rotate 	: std_logic_vector (1 downto 0);
	

	component MPPT is
        port
        (
        	ADC_Volt_out: out std_logic_vector(7 downto 0);
        	ADC_Curr_out: out std_logic_vector(7 downto 0);
        	PWM_out: out std_logic;
        	main_clk: in std_logic;
        	add_sub_sig: in std_logic_vector(1 downto 0)
        );
        end component;
begin

	EPS_MPPT1: MPPT port map (
		ADC_Volt_out	=>	R2R_volt (7 downto 0),
		ADC_Curr_out	=>	R2R_curr (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		PWM_out			=>  LEDR(9),                 -- Skal sættes til en GPIO pin!
		main_clk		=>	CLOCK2_50
	);

	EPS_MPPT2: MPPT port map (
		ADC_Volt_out	=>	R2R_volt (7 downto 0),
		ADC_Curr_out	=>	R2R_curr (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		PWM_out			=>  LEDR(8),                 -- Skal sættes til en GPIO pin!
		main_clk		=>	CLOCK2_50
	);

	EPS_MPPT3: MPPT port map (
		ADC_Volt_out	=>	R2R_volt (7 downto 0),
		ADC_Curr_out	=>	R2R_curr (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		PWM_out			=>  LEDR(7),                 -- Skal sættes til en GPIO pin!
		main_clk		=>	CLOCK2_50
	);


	R2R_volt <= GPIO_1 (7 downto 0);
	R2R_curr <= GPIO_1 (17 downto 10);
	rotate(0) <= GPIO_1(34);
	rotate(1) <= GPIO_1(35);


	clockscaler1 : process(all )
	begin
		if rising_edge (CLOCK2_50) then
			scaler <= scaler + 1;

			if scaler = "1000000000000" then
				scaler <= "0000000000000";
				rotate <= rotate + '1' ;

				if rotate = "11" then
					rotate <= "00";
				end if ;

			end if ;
		end if ;
		
	end process ; -- clockscaler1

end;
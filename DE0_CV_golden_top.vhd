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

	signal R2R_volt  	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal R2R_curr  	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal R2R_volt1 	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal R2R_curr1 	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal R2R_volt2 	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal R2R_curr2 	: std_logic_vector (7 downto 0); --Forskellige signaler for adc'erne i MPPT sub-modulerne
	signal rotate 	 	: std_logic_vector (2 downto 0):= "100"; --Signal til rotaion mellem MPPT'erne
	signal M_x		 	: std_logic_vector (1 downto 0); --Signal til multiplexerne på dev-board
	
	signal Enable_1  	: std_logic_vector (2 downto 0) := "100"; --Enable signal til MPPT submodul
	signal Enable_2  	: std_logic_vector (2 downto 0) := "010"; --Enable signal til MPPT submodul
	signal Enable_3  	: std_logic_vector (2 downto 0) := "001"; --Enable signal til MPPT submodul

	signal PWM_clk_top	: std_logic; --Clock som skal  bruges til rotation (kommer fra MPPT submodul)


	component MPPT is
        port
        (
        	ADC_Volt_out 	: out std_logic_vector(7 downto 0);
        	ADC_Curr_out 	: out std_logic_vector(7 downto 0);
			add_sub_sig	 	: in std_logic_vector(1 downto 0);
			main_clk		: in std_logic;
        	PWM_out			: out std_logic;
			Rotate 			: in std_logic_vector(2 downto 0);
			Enable			: in std_logic_vector(2 downto 0);
			PWM_clk_top		: out std_logic
        );
        end component;
begin

	EPS_MPPT1: MPPT port map (
		ADC_Volt_out(7 downto 0)	=>	R2R_volt (7 downto 0), --adc pins
		ADC_Curr_out(7 downto 0)	=>	R2R_curr (7 downto 0), --adc pins
		add_sub_sig		=>	GPIO_0 (1 downto 0), -- input fra comparator
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(33),             -- PWM output fra MPPT submodul
		Rotate 			=>	rotate (2 downto 0),    -- Rotation mellem MPPT'erne
		Enable			=>	Enable_1 (2 downto 0),  -- Enable til MPPT-submodulerne
		PWM_clk_top  	=>	PWM_clk_top -- Clock der hives til til at styre rotations mellem MPPT'erne
	);

	EPS_MPPT2: MPPT port map ( --Samme som tidligere instance
		ADC_Volt_out(7 downto 0)	=>	R2R_volt1 (7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	R2R_curr1 (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(32),             
		Rotate 			=>	rotate (2 downto 0),
		Enable			=>	Enable_2 (2 downto 0)
	);

	EPS_MPPT3: MPPT port map ( --Samme som tidligere instance
		ADC_Volt_out(7 downto 0)	=>	R2R_volt2 (7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	R2R_curr2 (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),	
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(31),  
		Rotate 			=>	rotate (2 downto 0),
		Enable			=>	Enable_3 (2 downto 0)
	);

	M_x(0) <= GPIO_1(34); --Styring af multiplexer på dev-board
	M_x(1) <= GPIO_1(35); --Styring af multiplexer på dev-board

	with rotate select M_x <= --Her sendes værdien ud til multiplexeren på dev-board
		"00" when "100", 
		"01" when "010",  
		"10" when "001",
		"00" when others;

with rotate select GPIO_1(7 downto 0) <= -- Her skiftes der mellem hvilken ADC (volt) der har forbindelse til R2R ladders
		R2R_volt when "100", 
		R2R_volt1 when "010",  
		R2R_volt2 when "001",
		R2R_volt when others;

		with rotate select GPIO_1(17 downto 10) <= -- Her skiftes der mellem hvilken ADC (strøm) der har forbindelse til R2R ladders
		R2R_curr when "100", 
		R2R_curr1 when "010",  
		R2R_curr2 when "001",
		R2R_volt when others;
	
	Rotation : process( all )
	begin
		if rising_edge( PWM_clk_top ) then
			rotate <= rotate(0) & rotate(2 downto 1);
		end if ;
	end process ; -- Rotation
end;
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

	signal R2R_volt : std_logic_vector (7 downto 0);
	signal R2R_curr : std_logic_vector (7 downto 0);
	signal R2R_volt1 : std_logic_vector (7 downto 0);
	signal R2R_curr1 : std_logic_vector (7 downto 0);
	signal R2R_volt2 : std_logic_vector (7 downto 0);
	signal R2R_curr2 : std_logic_vector (7 downto 0);
	signal scaler 	: unsigned (14 downto 0);
	signal rotate 	: std_logic_vector (2 downto 0):= "100";
	-- signal M_x		: std_logic_vector (1 downto 0);
	signal PWM_clk3	: std_logic;
	
	signal Enable_1 : std_logic_vector (2 downto 0) := "100";
	signal Enable_2 : std_logic_vector (2 downto 0) := "010";
	signal Enable_3 : std_logic_vector (2 downto 0) := "001";

	signal PWM_clk_top : std_logic;


	component MPPT is
        port
        (
			clockscalekey	: in std_logic;							-- Test af ADC klokken med en Key
        	ADC_Volt_out 	: out std_logic_vector(7 downto 0);
        	ADC_Curr_out 	: out std_logic_vector(7 downto 0);
			clockscale10 	: out std_logic;
			add_sub_sig	 	: in std_logic_vector(1 downto 0);
			PWM_clk3	 	: out std_logic;
			main_clk		: in std_logic;
        	PWM_out			: out std_logic;
			Rotate 			: in std_logic_vector(2 downto 0);
			Enable			: in std_logic_vector(2 downto 0);
			vej_h1			: out std_logic
        );
        end component;
begin

	EPS_MPPT1: MPPT port map (
		clockscalekey	=> 	not KEY(0),					-- Test af ADC klokken med en Key
		ADC_Volt_out(7 downto 0)	=>	R2R_volt (7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	R2R_curr (7 downto 0),
		clockscale10	=>	PWM_clk_top,             -- Test af ADC klokken 
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		PWM_clk3		=>	PWM_clk3,				-- Test af PWM klokken
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(32),             -- Skal sættes til en GPIO pin!
		Rotate 			=>	rotate (2 downto 0),
		Enable			=>	Enable_1 (2 downto 0),
		vej_h1			=> LEDR(9)
	);

	EPS_MPPT2: MPPT port map (
		clockscalekey	=> 	not KEY(0),					-- Test af ADC klokken med en Key
		ADC_Volt_out(7 downto 0)	=>	R2R_volt1 (7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	R2R_curr1 (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(31),                -- Skal sættes til en GPIO pin!
		Rotate 			=>	rotate (2 downto 0),
		Enable			=>	Enable_2 (2 downto 0),
		vej_h1			=> LEDR(8)
	);

	EPS_MPPT3: MPPT port map (
		clockscalekey	=> 	not KEY(0),					-- Test af ADC klokken med en Key
		ADC_Volt_out(7 downto 0)	=>	R2R_volt2 (7 downto 0),
		ADC_Curr_out(7 downto 0)	=>	R2R_curr2 (7 downto 0),
		add_sub_sig		=>	GPIO_0 (1 downto 0),	
		main_clk		=>	CLOCK2_50,
		PWM_out			=>  GPIO_1(30),                 -- Skal sættes til en GPIO pin!
		Rotate 			=>	rotate (2 downto 0),
		Enable			=>	Enable_3 (2 downto 0),
		vej_h1			=> LEDR(7)
	);

	GPIO_1(34)  <= PWM_clk_top;	
	LEDR(2 downto 0) <= rotate(2 downto 0);
	GPIO_1(33) <= PWM_clk3;
	-- M_x(0) <= GPIO_1(34);
	-- M_x(1) <= GPIO_1(35);

	-- with rotate select M_x <=
	-- 	"00" when "100", 
	-- 	"01" when "010",  
	-- 	"10" when "001",
	-- 	"00" when others;

with rotate select GPIO_1(7 downto 0) <=
		R2R_volt when "100", 
		R2R_volt1 when "010",  
		R2R_volt2 when "001",
		R2R_volt when others;

		with rotate select GPIO_1(17 downto 10) <=
		R2R_curr when "100", 
		R2R_curr1 when "010",  
		R2R_curr2 when "001",
		R2R_volt when others;
	
	clockscaler1 : process( all )
	begin
		if rising_edge (CLOCK2_50) then
			scaler <= scaler + 1;
		end if;
		if rising_edge(PWM_clk3) then
			rotate <= rotate(0) & rotate(2 downto 1);
		end if ;
	end process ; -- clockscaler1
end;
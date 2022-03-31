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
		GPIO_1 		: out std_logic_vector(35 downto 0); --Clock er sat meget ned for at teste
		KEY 		: in std_logic_vector(3 downto 0);
		LEDR 		: out std_logic_vector(9 downto 0);
		SW 			: in std_logic_vector(9 downto 0)
	);

end DE0_CV_golden_top;

architecture ppl_type of DE0_CV_golden_top is

	signal clk 				: std_logic;
	signal add_sub_sig 		: std_logic;
	signal sel_sig 			: std_logic_vector(2 downto 0);
	signal clockscale		: unsigned(24 downto 0);
	signal result_sig_volt	: std_logic_vector(7 downto 0);
	signal result_sig_curr	: std_logic_vector(7 downto 0);
	signal result_sig 		:std_logic_vector(15 downto 0);
	signal GPIO_1OUT		: std_logic_vector(17 downto 0);

	signal saveB16 		: std_logic_vector (15 downto 0);
	signal duty_cycle 	: unsigned (3 downto 0) := "0000";
	-- signal saveA 		: std_logic_vector (15 downto 0);
	signal vej_h 		: std_logic; 
	signal comp_out 	: std_logic_vector (2 downto 0);
	signal PWM_clk 		: unsigned (3 downto 0);

	component ADC is
	port (
		clk         	: in std_logic;
		gpio1       	: out std_logic_vector(35 downto 0);
		result_sig_out  : out std_logic_vector (7 downto 0);
		add_sub_sig 	: in std_logic
	) ;
	end component;

	component sixteenBitComparator is
		port (
			saveA16	: in std_logic_vector (15 downto 0);
			saveB16	: in std_logic_vector (15 downto 0);
			exIn16	: in std_logic_vector (2 downto 0);
			exOut16	: out std_logic_vector (2 downto 0)
			);
		end component;
		
	component PWM_submodule is
		port (
			pwm_out 	: out std_logic;
			duty_cycle 	: in std_logic_vector(3 downto 0);
			clk 		: in std_logic
		);
	end component;
  

begin
	-- ADC volt
	adc_volt : ADC port map (
			clk 				=> clockscale(24),	-- 1hz clock,
			gpio1(7 downto 0)	=> GPIO_1OUT(7 downto 0),
			result_sig_out		=> result_sig_volt,
			add_sub_sig 		=> GPIO_0(0)
		);

	adc_curr : ADC port map(
			clk					=> clockscale(24), -- 1hz clock,
			gpio1(7 downto 0)	=> GPIO_1OUT(17 downto 10),
			result_sig_out		=> result_sig_curr,
			add_sub_sig 		=> GPIO_0(1)
		);

	PWM_comp : PWM_submodule port map (
			pwm_out 	=> LEDR(9), --PWM output er sat til en LED
			duty_cycle 	=> std_logic_vector(duty_cycle),
			clk 		=> CLOCK2_50
		);

	Comp1 : sixteenBitComparator port map ( 
			saveA16(15 downto 0) => result_sig(15 downto 0),
			saveB16(15 downto 0) => saveB16(15 downto 0),
			exIn16(1) 			 => '1',
			exOut16(2 downto 0)  => comp_out(2 downto 0)
		);


	-- Write final adc value to comparator
		result_sig(15 downto 0) <= std_logic_vector(unsigned(result_sig_curr(7 downto 0)) * unsigned(result_sig_volt(7 downto 0)));
	-- Write multiplexer output to DAC
		GPIO_1(17 downto 0) 	<= GPIO_1OUT(17 downto 0);
	-- Sætter ADC resultat ud på LED'er for at teste
		LEDR(7 downto 0) 		<= result_sig(15 downto 8);
	-- Når a = b lyser LED 9
		LEDR(8) <= comp_out(1);
	-- Scale clock from 50MHz 
	clockscaler : process( CLOCK2_50 )
	begin
		if rising_edge(CLOCK2_50) then
			clockscale <= clockscale + 1 ;
		end if ;
	end process ; -- clockscaler

	PWM_clockscaler : process( clockscale(24) )
	begin
		if rising_edge(clockscale(24)) then
			PWM_clk <= PWM_clk + 1 ;
		end if ;
	end process ; -- PWM_clockscaler
	

	MPPT_algoritme : process( all )
		begin
			-- MPPT algoritme
			if rising_edge( PWM_clk(3) ) then
				--opstart
				if saveB16(15 downto 0) = "0000000000000000" then
					saveB16(15 downto 0) <= result_sig(15 downto 0);
					duty_cycle <= duty_cycle + 1;
					vej_h <= '1';
				end if ;

				--Funktion til højre
				if vej_h = '1' then
					if comp_out(0) = '1' or comp_out(1) = '1' then --b>a
						duty_cycle <= duty_cycle - 1;
						vej_h <= '0';
						saveB16(15 downto 0) <= result_sig(15 downto 0);
					end if;
					if comp_out(2) = '1' then --a>b
						duty_cycle <= duty_cycle + 1;
						vej_h <= '1';
						saveB16(15 downto 0) <= result_sig(15 downto 0);
					end if ;
					
				end if ;

				--Funktion til venstre 
				if vej_h = '0' then
					if comp_out(0) = '1' then --b>a
						duty_cycle <= duty_cycle + 1;
						vej_h <= '1';
						saveB16(15 downto 0) <= result_sig(15 downto 0);
					end if;
					if comp_out(2) = '1' or comp_out(1) = '1' then --a>b
						duty_cycle <= duty_cycle - 1;
						vej_h <= '0';
						saveB16(15 downto 0) <= result_sig(15 downto 0);
					end if ;
				end if;	
			end if;		
		end process ; -- MPPT-algoritme

end;

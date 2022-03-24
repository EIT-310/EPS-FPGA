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
		GPIO_0 : in std_logic_vector(35 downto 0);
		GPIO_1 : out std_logic_vector(35 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		SW : in std_logic_vector(9 downto 0)
	);

end DE0_CV_golden_top;

architecture ppl_type of DE0_CV_golden_top is

	signal clk 		: std_logic;
	signal add_sub_sig : std_logic;
	signal sel_sig 	: std_logic_vector(2 downto 0);
	signal clockscale	: unsigned(10 downto 0);
	signal result_sig	: std_logic_vector(7 downto 0);
	signal GPIO_1OUT	: std_logic_vector(7 downto 0);

	component ADC is
	port (
		clk         : in std_logic;
		gpio1       : out std_logic_vector(35 downto 0);
		result_sig_out  : out std_logic_vector (7 downto 0);
		add_sub_sig : in std_logic
	) ;
	end component;
  

begin
		-- ADC Inst
			adc_inst : ADC port map (
			clk 				=> clockscale(10),	-- 1hz clock,
			gpio1(7 downto 0)	=> GPIO_1OUT(7 downto 0),
			result_sig_out		=> result_sig,
			add_sub_sig 		=> GPIO_0(0)
		);


	-- Write final adc value to LED
	display : for i in 0 to 7 generate
		LEDR(i) <= result_sig(i);
	end generate ; -- display


	-- Write multiplexer output to DAC
	GPIO_write : for i in 0 to 7 generate
		GPIO_1(i) <= GPIO_1OUT(i);
	end generate ; -- GPIO_write 


	-- Scale clock from 50MHz 
	clockscaler : process( CLOCK2_50 )
	begin
		if rising_edge(CLOCK2_50) then
			clockscale <= clockscale + 1 ;
		end if ;
	end process ; -- clockscaler
	
end;

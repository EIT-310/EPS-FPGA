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
	
	type byte_arr is array (7 downto 0) of std_logic_vector (7 downto 0);
	signal dataa_arr: byte_arr;

	signal rotate 	: std_logic_vector(7 downto 0) := "10000000";
	signal clk 		: std_logic;
	signal add_sub_sig : std_logic;
	signal sel_sig 	: std_logic_vector(2 downto 0);
	signal clockscale	: unsigned(10 downto 0);
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

begin

	add_sub_sig <= GPIO_0(0); 		-- input from coparator
	clk 		<= clockscale(10);	-- 1hz clock
	GPIO_1(35)	<= clk;				-- write clock for debug	
	--always start ADC in middle
	dataa_arr(0)<= "10000000";


	-- Write final adc value to LED
	display : for i in 0 to 7 generate
		LEDR(i) <= dataa_arr(7)(i);
	end generate ; -- display


	-- Write multiplexer output to DAC
	GPIO_write : for i in 0 to 7 generate
		GPIO_1(i) <= result_sig(7-i);
	end generate ; -- GPIO_write 


	-- Scale clock from 50MHz to ca. 1Hz
	clockscaler : process( CLOCK2_50 )
	begin
		if rising_edge(CLOCK2_50) then
			clockscale <= clockscale + 1 ;
		end if ;
	end process ; -- clockscaler

	
	-- Rotate data to be added/subtracted
	rotator : process(clk)
	begin
		if rising_edge(clk) then
			rotate <= rotate(0) & rotate(7 downto 1);
		end if ;
	end process ; -- rotator
	

	-- Generate 6 Addders
	adder_loop : for i in 0 to 6 generate
		adder_inst : adder port map (
			clock => rotate(6-i),
			add_sub => add_sub_sig,
			dataa => dataa_arr(i),
			datab => rotate,
			result => dataa_arr(i+1)
		);
	end generate ; -- adder_loop
	
	-- Multiplexer for DAC
	with rotate select result_sig <=
		dataa_arr(0) when "10000000", -- Do nothing first cycle
		dataa_arr(0) when "01000000", -- Write prev. byte to DAC when add/sub  
		dataa_arr(1) when "00100000",
		dataa_arr(2) when "00010000", -- When DAC is      10000000 
		dataa_arr(3) when "00001000", -- we wanna add/sub 01000000
		dataa_arr(4) when "00000100", -- and so on
		dataa_arr(5) when "00000010",
		dataa_arr(6) when "00000001",
		dataa_arr(7) when others;

end;

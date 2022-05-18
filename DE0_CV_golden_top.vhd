library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

--! Topfilen (også kaldet testbench) er en implementation af moduler
--! specifik til en given opstilling, porte er koblet til fysiske
--! pins på FPGA devboardet.
entity DE0_CV_golden_top is
	port
	(
		CLOCK2_50 	: in 	std_logic;							--! Clock port forbundet til 40MHz clock på devboardet
		GPIO_0		: in 	std_logic_vector(35 downto 0);		--! 20x2 box header connector hvor 2 pins er GND og 2 er forsyning
		GPIO_1 		: out	std_logic_vector(35 downto 0);		--! 20x2 box header connector hvor 2 pins er GND og 2 er forsyning
		KEY 		: in 	std_logic_vector(3 downto 0);		--! 4 knapper på devoardet til manuel input - bruges til debugging
		LEDR 		: out	std_logic_vector(9 downto 0);		--! 10 LED'er på devboardet - bruges til debugging
		SW 			: in 	std_logic_vector(9 downto 0)		--! 10 switches på devboardet - bruges til debugging
	);

end DE0_CV_golden_top;

architecture arch of DE0_CV_golden_top is

	signal PWM_mes : std_logic; --! Signal til at kunne få PWM signalet ud på to GPIO pins.

	--! MPPT submodul.
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
	--! Instance af MPPT submodul.
	EPS_MPPT1: MPPT port map (
		ADC_Volt_out(7 downto 0)	=>	GPIO_1(7 downto 0), 	--! ADC-volt forbindes til GPIO  output pins.
		ADC_Curr_out(7 downto 0)	=>	GPIO_1(17 downto 10),	--! ADC-curr forbindes til GPIO  output pins.
		add_sub_sig		=>	GPIO_0 (1 downto 0),				--! add_sub_sig forbindes til GPIO input pins.
		main_clk		=>	CLOCK2_50,							--! Submodulets clock forbindes til den fysiske.
		PWM_out			=>  PWM_mes								--! PWM outputtet forbindes til testbench signalet.
	);

	GPIO_1(33) <= PWM_mes; --! PWM signal til prototypen.
	GPIO_1(32) <= PWM_mes; --! PWM signal til debugging.
end;
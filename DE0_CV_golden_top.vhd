library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

--! Topfilen opstilles.
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

	signal PWM_mes : std_logic; --! Signal til at kunne få PWM signalet ud på to GPIO pins.
	--! MPPT submodul defineres.
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
	--! Instance af MPPT submodul kaldes.
	EPS_MPPT1: MPPT port map (
		ADC_Volt_out(7 downto 0)	=>	GPIO_1(7 downto 0), 	--! ADC-volt forbindes til GPIO pins.
		ADC_Curr_out(7 downto 0)	=>	GPIO_1(17 downto 10),	--! ADC-curr forbindes til GPIO pins.
		add_sub_sig		=>	GPIO_0 (1 downto 0),				--! add_sub_sig forbindes til GPIO pins.
		main_clk		=>	CLOCK2_50,							--! Main clock forbindes til submodulerne.
		PWM_out			=>  PWM_mes								--! PWM outputtet forbindes.
	);

	GPIO_1(33) <= PWM_mes; --! PWM signal til devboardet.
	GPIO_1(32) <= PWM_mes; --! PWM signal til måling.
end;
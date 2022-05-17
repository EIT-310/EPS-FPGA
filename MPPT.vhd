library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--! 
entity MPPT is
    port (
        ADC_Volt_out	: out std_logic_vector(7 downto 0);
        ADC_Curr_out	: out std_logic_vector(7 downto 0);
		add_sub_sig		: in std_logic_vector(1 downto 0);
		main_clk		: in std_logic;
        PWM_out			: out std_logic;
		res_sig			: out std_logic_vector(7 downto 0)
      ) ;
  end MPPT ;

  architecture arch of MPPT is

	signal adc_clk			: unsigned(15 downto 0); 			--! Signal til at downscale main clock.
	signal result_sig_volt	: std_logic_vector(7 downto 0); 	--! Vector til at gemme resultatet fra ADC.
	signal result_sig_curr	: std_logic_vector(7 downto 0); 	--! Vector til at gemme resultatet fra ADC.
	signal result_sig 		: std_logic_vector(15 downto 0); 	--! Vector til at gemme resultatet fra ADC.
	signal vej_h			: std_logic; 						--! Værdi, som holder styr på hvilken vej algorithmen lige har gået.

	signal result_sig_old 	: std_logic_vector (15 downto 0) := (others => '0'); 	--! Den forrige værdi for effekten
	signal duty_cycle 		: unsigned (6 downto 0) := (others => '0'); 			--! Duty cycle som går ned i PWM sub modulet.
	signal comp_out 		: std_logic_vector (2 downto 0); 						--! Outputs fra sixteenbit comparatoren.
	signal MPPT_clk 		: unsigned (2 downto 0) := "100";						--! Clock for PWM signal.

	--! Herefter opstilles alle submodulerne.
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
			duty_cycle 	: in std_logic_vector(6 downto 0);
			clk 		: in std_logic
		);
	end component;
  

begin
	--! Her kaldes alle instances af submodulerne.
	
	--! ADC til måling af volt over solcellerne.
	adc_volt : ADC port map (
			clk 				=> adc_clk(15), 				--! Clock til adc
			gpio1(7 downto 0)	=> ADC_Volt_out(7 downto 0), 	
			result_sig_out		=> result_sig_volt,
			add_sub_sig 		=> add_sub_sig(0)
		);

	--! ADC til måling af volt over shuntmodstand, hvilket er afhængig af strømmen igennem mondstanden.
	adc_curr : ADC port map(
			clk					=> adc_clk(15),
			gpio1(7 downto 0)	=> ADC_Curr_out(7 downto 0),
			result_sig_out		=> result_sig_curr,
			add_sub_sig 		=> add_sub_sig(1)
		);

	--! PWM generator til buck/boost conveteren.
	PWM_comp : PWM_submodule port map (
			pwm_out 		=> PWM_out,
			duty_cycle 		=> std_logic_vector(duty_cycle),
			clk 			=> main_clk
		);

	--! Sixteenbitcomparator til at compare effekten fra solcellerne.
	Comp1 : sixteenBitComparator port map ( 
			saveA16(15 downto 0) 	=> result_sig(15 downto 0),
			saveB16(15 downto 0) 	=> result_sig_old(15 downto 0),
			exIn16(1) 			 	=> '1',
			exIn16(2)				=> '0',
			exIn16(0)				=> '0',
			exOut16(2 downto 0)  	=> comp_out(2 downto 0)
		);

	--! Clockscaler: downscale fra main-clk til ADC, for at comparator modulet kan følge med.
	clockscaler : process( all )
	begin
		if rising_edge(main_clk) then
			adc_clk <= adc_clk + 1 ;
		end if ;
	end process ; -- clockscaler

	--Clockscaler: Downscale adc-clk (adc_clk(15)) til MPPT_clk
	PWM_clockscaler : process( all )
	begin
		if falling_edge(adc_clk(15)) then
			MPPT_clk <= MPPT_clk + 1 ;
		end if ;
	end process ; -- PWM_clockscaler

	--!  Ganger resultaterne fra de to adc sammen til en repræsentation af effekten.
	result_sig(15 downto 0) <= std_logic_vector(unsigned(result_sig_curr(7 downto 0)) * unsigned(result_sig_volt(7 downto 0)));
	
	
	MPPT_algoritme : process( all )
		begin
				--!  MPPT algoritme
				if rising_edge( MPPT_clk(2) ) then
				--opstart
        
					if result_sig_old(15 downto 0) = "0000000000000000" then
						result_sig_old(15 downto 0) <= result_sig(15 downto 0);
						duty_cycle <= duty_cycle + 1;
						vej_h <= '0';
					end if ;

					--Funktion til højre
					if vej_h = '1' then
						if comp_out(0) = '1' or comp_out(1) = '1' then --b>a
							duty_cycle <= duty_cycle + 1;
							vej_h <= '0';
							result_sig_old(15 downto 0) <= result_sig(15 downto 0);
						end if;
						if comp_out(2) = '1' then --a>b
							duty_cycle <= duty_cycle - 1;
							vej_h <= '1'; --overflødig linje
							result_sig_old(15 downto 0) <= result_sig(15 downto 0);
						end if ;
					
					end if ;

					--Funktion til venstre 
					if vej_h = '0' then
						if comp_out(0) = '1' then --b>a
							duty_cycle <= duty_cycle - 1;
							vej_h <= '1';
							result_sig_old(15 downto 0) <= result_sig(15 downto 0);
						end if;
						if comp_out(2) = '1' or comp_out(1) = '1' then --a>b
							result_sig_old(15 downto 0) <= result_sig(15 downto 0);
							duty_cycle <= duty_cycle + 1;
							vej_h <= '0'; --overflødig linje
						end if ;
					end if;	
				end if;		
			
		end process ; -- MPPT-algoritme

end;
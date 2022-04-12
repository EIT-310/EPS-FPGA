library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MPPT is
    port (
		clockscalekey	: in std_logic;
        ADC_Volt_out	: out std_logic_vector(7 downto 0);
        ADC_Curr_out	: out std_logic_vector(7 downto 0);
		clockscale10	: out std_logic;                        -- test af klokken
		add_sub_sig		: in std_logic_vector(1 downto 0);
		main_clk		: in std_logic;
		PWM_clk3		: out std_logic;						-- test af klokken
        PWM_out			: out std_logic;
		Rotate 			: in std_logic_vector(2 downto 0);
		Enable			: in std_logic_vector(2 downto 0);
		vej_h1			: out std_logic
      ) ;
  end MPPT ;

  architecture MPPT of MPPT is

	signal clockscale		: unsigned(10 downto 0);
	signal result_sig_volt	: std_logic_vector(7 downto 0);
	signal result_sig_curr	: std_logic_vector(7 downto 0);
	signal result_sig 		:std_logic_vector(15 downto 0);

	signal saveB16 		: std_logic_vector (15 downto 0);
	signal duty_cycle 	: unsigned (3 downto 0) := "0000";
	signal vej_h 		: std_logic; 
	signal comp_out 	: std_logic_vector (2 downto 0);
	signal PWM_clk 		: unsigned (2 downto 0) := "100";

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
			clk					=> clockscalekey,
			-- clk 				=> clockscale(10),
			gpio1(7 downto 0)	=> ADC_Volt_out(7 downto 0),
			result_sig_out		=> result_sig_volt,
			add_sub_sig 		=> add_sub_sig(0)
		);

	adc_curr : ADC port map(
			clk					=> clockscalekey,
			-- clk					=> clockscale(10),
			gpio1(7 downto 0)	=> ADC_Curr_out(7 downto 0),
			result_sig_out		=> result_sig_curr,
			add_sub_sig 		=> add_sub_sig(1)
		);

	PWM_comp : PWM_submodule port map (
			pwm_out 		=> PWM_out,
			duty_cycle 		=> std_logic_vector(duty_cycle),
			clk 			=> main_clk
		);

	Comp1 : sixteenBitComparator port map ( 
			saveA16(15 downto 0) 	=> result_sig(15 downto 0),
			saveB16(15 downto 0) 	=> saveB16(15 downto 0),
			exIn16(1) 			 	=> '1',
			exOut16(2 downto 0)  	=> comp_out(2 downto 0)
		);

-- Write final adc value to comparator
result_sig(15 downto 0) <= std_logic_vector(unsigned(result_sig_curr(7 downto 0)) * unsigned(result_sig_volt(7 downto 0)));

clockscale10	<= clockscalekey;		--Lavet for at teste, så klokken styres af en knap
-- clockscale10 	<= clockscale(10);         -- Clockscale10 	= ADC klokken
PWM_clk3 		<= PWM_clk(2);          -- PWM_clk3 		= 1/8 ADC klokken
vej_h1 			<= vej_h;				-- Lavet for at kunne trække vej_h ud til en LED
	clockscaler : process( all )            -- Scale clock from 50MHz 
	begin

		if rising_edge(main_clk) then
			clockscale <= clockscale + 1 ;
		end if ;
	end process ; -- clockscaler

	PWM_clockscaler : process( all )
	begin
		if rising_edge(clockscalekey) then
			PWM_clk <= PWM_clk + 1 ;
		end if ;

		-- if rising_edge(clockscale(10)) then
		-- 	PWM_clk <= PWM_clk + 1 ;
		-- end if ;
	end process ; -- PWM_clockscaler

	

	MPPT_algoritme : process( all )
		begin
			if Enable = Rotate then  -- Enabel pin = rotate, so you can switch between the 3 MPPT's
				-- MPPT algoritme
				if rising_edge( PWM_clk(2) ) then
				--opstart
        
					if saveB16(15 downto 0) = "0000000000000000" then
						saveB16(15 downto 0) <= result_sig(15 downto 0);
						duty_cycle <= duty_cycle + 1;
						vej_h <= '0';
					end if ;

					--Funktion til højre
					if vej_h = '1' then
						if comp_out(0) = '1' or comp_out(1) = '1' then --b>a
							duty_cycle <= duty_cycle + 1;
							vej_h <= '0';
							saveB16(15 downto 0) <= result_sig(15 downto 0);
						end if;
						if comp_out(2) = '1' then --a>b
							duty_cycle <= duty_cycle - 1;
							vej_h <= '1'; --overflødig linje
							saveB16(15 downto 0) <= result_sig(15 downto 0);
						end if ;
					
					end if ;

					--Funktion til venstre 
					if vej_h = '0' then
						if comp_out(0) = '1' then --b>a
							duty_cycle <= duty_cycle - 1;
							vej_h <= '1';
							saveB16(15 downto 0) <= result_sig(15 downto 0);
						end if;
						if comp_out(2) = '1' or comp_out(1) = '1' then --a>b
							duty_cycle <= duty_cycle + 1;
							vej_h <= '0'; --overflødig linje
							saveB16(15 downto 0) <= result_sig(15 downto 0);
						end if ;
					end if;	
				end if;		
			end if ;
			
		end process ; -- MPPT-algoritme

end;
library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;
use ieee.numeric_std.all;

entity DE0_CV_golden_top is
	port (
		CLOCK2_50 : in std_logic;
		CLOCK3_50 : in std_logic;
		CLOCK4_50 : in std_logic;
		CLOCK_50 : in std_logic;
		DRAM_CAS_N : in std_logic;
		DRAM_CKE : in std_logic;
		DRAM_CLK : in std_logic;
		DRAM_CS_N : in std_logic;
		DRAM_LDQM : in std_logic;
		DRAM_RAS_N : in std_logic;
		DRAM_UDQM : in std_logic;
		DRAM_WE_N : in std_logic;
		PS2_CLK : in std_logic;
		PS2_CLK2 : in std_logic;
		PS2_DAT : in std_logic;
		PS2_DAT2 : in std_logic;
		RESET_N : in std_logic;
		SD_CLK : in std_logic;
		SD_CMD : in std_logic;
		VGA_HS : in std_logic;
		VGA_VS : in std_logic;
		DRAM_ADDR : in std_logic_vector(12 downto 0);
		DRAM_BA : in std_logic_vector(1 downto 0);
		DRAM_DQ : in std_logic_vector(15 downto 0);
		GPIO_0 : in std_logic_vector(35 downto 0);
		GPIO_1 : in std_logic_vector(35 downto 0);
		HEX0 : in std_logic_vector(6 downto 0);
		HEX1 : in std_logic_vector(6 downto 0);
		HEX2 : in std_logic_vector(6 downto 0);
		HEX3 : in std_logic_vector(6 downto 0);
		HEX4 : in std_logic_vector(6 downto 0);
		HEX5 : in std_logic_vector(6 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		SD_DATA : in std_logic_vector(3 downto 0);
		SW : in std_logic_vector(9 downto 0);
		VGA_B : in std_logic_vector(3 downto 0);
		VGA_G : in std_logic_vector(3 downto 0);
		VGA_R : in std_logic_vector(3 downto 0)
	);

end DE0_CV_golden_top;

architecture MPPT of DE0_CV_golden_top is
signal saveB : std_logic_vector (7 downto 0);
signal duty_cycle : unsigned (3 downto 0);
signal saveA : std_logic_vector (7 downto 0);
signal vej_h : std_logic; 
signal comp_out : std_logic_vector (2 downto 0);

component eightBitComparator is
port (
	saveA: in std_logic_vector (7 downto 0);
    saveB: in std_logic_vector (7 downto 0);
    exIn: in std_logic_vector (2 downto 0);
    exOut: out std_logic_vector (2 downto 0)
	);
end component;

component PWM_submodule is
	port (
		pwm_out : out std_logic;
    	duty_cycle : in std_logic_vector(3 downto 0);
    	clk : in std_logic
	);
end component;

begin
saveA(7 downto 0) <= SW(7 downto 0);
LEDR(9 downto 7) <= comp_out(2 downto 0);
LEDR(5) <= vej_h;

PWM_comp : PWM_submodule port map (
		pwm_out => LEDR(0),
		duty_cycle => std_logic_vector(duty_cycle),
		clk => CLOCK_50
	);

Comp1 : eightBitComparator port map ( 
		saveA(7 downto 0) => saveA(7 downto 0),
		saveB(7 downto 0) => saveB(7 downto 0),
		exIn(1) => '1',
		exOut(2 downto 0) => comp_out(2 downto 0)
		);

	saveValue : process( KEY )
		begin
			if rising_edge(key(0)) then
				saveB(7 downto 0) <= saveA(7 downto 0);
			end if;

			if rising_edge(key(1)) then
				--opstart
				if saveB(7 downto 0) = "00000000" then
					--saveB(7 downto 0) <= saveA(7 downto 0);
					duty_cycle <= duty_cycle + 1;
					vej_h <= '1';
				end if ;

				--Funktion til højre
				if vej_h = '1' then
					if comp_out(0) = '1' or comp_out(1) = '1' then --b>a
						duty_cycle <= duty_cycle - 1;
						vej_h <= '0';
						--saveB(7 downto 0) <= saveA(7 downto 0);
					end if;
					if comp_out(2) = '1' then --a>b
						duty_cycle <= duty_cycle + 1;
						vej_h <= '1';
						--saveB(7 downto 0) <= saveA(7 downto 0);
					end if ;
					
				end if ;

				--Funktion til venstre 
				if vej_h = '0' then
					if comp_out(0) = '1' then --b>a
						duty_cycle <= duty_cycle + 1;
						vej_h <= '1';
						--saveB(7 downto 0) <= saveA(7 downto 0);
					end if;
					if comp_out(2) = '1' or comp_out(1) = '1' then --a>b
						duty_cycle <= duty_cycle - 1;
						vej_h <= '0';
						--saveB(7 downto 0) <= saveA(7 downto 0);
					end if ;
				end if;	
			end if;		
		end process ; -- saveValue
		
end;




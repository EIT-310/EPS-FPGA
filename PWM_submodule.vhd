library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_submodule is

	port
	(
    pwm_out : out std_logic;
    duty_cycle : in std_logic_vector(3 downto 0);
    clk : in std_logic
    );
end; 

architecture PWM of PWM_submodule is
    signal cnt : unsigned(3 downto 0);


begin
    PWM_signal : process( clk )
    begin
        if rising_edge( clk ) then
            cnt <= cnt + 1 ;
                if cnt > unsigned(duty_cycle) then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                    
                end if ;
            
        end if ;
    end process ; -- PWM_signal

end PWM ; -- PWM
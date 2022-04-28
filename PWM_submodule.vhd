library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_submodule is

	port
	(
    pwm_out : out std_logic;
    duty_cycle : in std_logic_vector(6 downto 0);
    clk : in std_logic
    );
end; 

architecture PWM of PWM_submodule is
    signal cnt : unsigned(6 downto 0);
    signal PWM_clockscaler : unsigned(2 downto 0);

begin
    PWM_clockscaler_pro : process( clk )
    begin
    if rising_edge(clk) then
        PWM_clockscaler <= PWM_clockscaler + 1;
    end if;
        
    end process; --PWM_clockscaler
    PWM_signal : process( PWM_clockscaler(2) )
    begin
        if rising_edge( PWM_clockscaler(2) ) then
            cnt <= cnt + 1 ;
                if cnt < unsigned(duty_cycle) then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                    
                end if ;
            
        end if ;
    end process ; -- PWM_signal

end PWM ; -- PWM
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Først laves der et submodul til PWM generatoren
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

    --Først laves en clockscaler for at reducere frekvensen på PWM signalet.
    --Dette gøres for at sikre spolen på MPPT-boarded kan når at op og aflade.
begin
    PWM_clockscaler_pro : process( clk )
    begin
    if rising_edge(clk) then
        PWM_clockscaler <= PWM_clockscaler + 1;
    end if;
    
    -- Her kører selve PWM generator koden. 
    -- Ved at ændre størrelsen på dutycycle ændrer man også hvor meget signalet er højt eller lavt.
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
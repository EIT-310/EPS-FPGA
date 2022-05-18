library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! \brief 7-bit PWM modul
--!
--! PWM modul består at en 7 bit repræsentation af duty cycle og en 7 bit counter.
--! counteren tæller op hver gang clocken har har rising edge. Så længe counteren
--! er lavere end dutycycle repræsentationen, vil output signalet være høj, og så
--! længe counteren er højere end dutycycle repræsentationen, vil output signalet
--! være lavt.
entity PWM_submodule is

	port
	(
    pwm_out : out std_logic;                        --! Signal der er højt eller lavt alt efter hvor vi er i duty cyclen
    duty_cycle : in std_logic_vector(6 downto 0);   --! 7-bit repræsentation af dutycycle \( (D) \) hvor \(\frac{D_{7bit}}{2^7} = D \\% \)
    clk : in std_logic                              --! Main clock uskaleret mht. PWM
    );
end; 

--! Arkitekturen for PWM generatoren.
architecture arch of PWM_submodule is
    signal cnt : unsigned(6 downto 0);              --! Counter repræsenterer hvor i dutycyclen vi er kommet, hvis denne er lavere end dc er pwm signal høj, og vice versa.
    signal PWM_clockscaler : unsigned(2 downto 0);  --! Clockscaler for at reducere frekvensen på PWM signalet
begin
    --! Clock frekvens \f$(f)\f$ scaleret mht. PWM perioden \f$(T)\f$ således \f$\frac{2^7}{f} = T\f$ 
    PWM_clockscaler_pro : process( clk )
    begin
    if rising_edge(clk) then
        PWM_clockscaler <= PWM_clockscaler + 1;
    end if;
    end process; --PWM_clockscaler
    
    --! Process der generer PWM signalet.
    --! PWM signalet bliver generet ved at cnt signalet tæller op med clocken.
    --! Når cnt er lavere end duty_cycle er output benet høj.
    --! Når cnt er højere end duty_cycle er output benet lavt.
    --! På den måde kan man ved at ændre duty_cycle bestemme hvor meget af tiden PWM signalet er højt og lavt.
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

end arch ; -- PWM
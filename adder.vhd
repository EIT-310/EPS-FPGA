library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

--! Modul adder består af en process der syntesiterer en clock aktiveret 8bit adder.
entity adder is
  port (
    clock : in std_logic;
    add_sub : in std_logic;
    dataa : in std_logic_vector (7 downto 0);
    datab : in std_logic_vector (7 downto 0);
    result: out std_logic_vector ( 7 downto 0)
  ) ;
end adder ; 

architecture arch of adder is

    signal u_dataa : unsigned (7 downto 0) := unsigned(dataa);  --! resultat fra tidligere adder
    signal u_datab : unsigned (7 downto 0) := unsigned(datab);  --! tal der skal lægges til / trækkes fra
    signal u_result: unsigned (7 downto 0);                     --! resultatet af adderen

begin
    --! Process der styres af signalet add_sub.
    --! Er add_sub = '1', vil u_dataa og u_datab blive lagt sammen og gemt i u_result.
    --! Er add_sub = '0', vil u_datab blive trukket fra u_dataa og gemt i u_result.
    artih : process( all )
    begin
        if (falling_edge(clock)) then
            if add_sub = '1' then
                u_result <= u_dataa + u_datab;
            else
                u_result <= u_dataa - u_datab;
            end if ;
        end if ;
    end process ; -- artih

    result <= std_logic_vector(u_result);
end architecture ;
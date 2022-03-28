library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;


entity eightBitComparator is
  port (
    saveA: in std_logic_vector (7 downto 0);
    saveB: in std_logic_vector (7 downto 0);
    exIn: in std_logic_vector (2 downto 0);
    exOut: out std_logic_vector (2 downto 0)
    ) ;
end eightBitComparator ;

architecture arch of eightBitComparator is
    signal carryOver : std_logic_vector (2 downto 0);
    component fourBitComparator is
        port
        (
            --tmp: 	inout std_logic_vector (0 to 27);
            A: 		in std_logic_vector (3 downto 0);
            B: 		in std_logic_vector (3 downto 0);
            ind: 	in std_logic_vector (2 downto 0);
            ud: 	out std_logic_vector (2 downto 0)
            );
            end component;
begin
    Comp1 : fourBitComparator port map ( 
        A(3 downto 0) => saveA(3 downto 0),
        B(3 downto 0) => saveB(3 downto 0),
        ind(2 downto 0) => exIn (2 downto 0),
        ud(2 downto 0) => carryOver(2 downto 0)
    );
    Comp2 : fourBitComparator port map (
        A(3 downto 0) => saveA(7 downto 4),
        B(3 downto 0) => saveB(7 downto 4),
        ind(2 downto 0) => carryOver (2 downto 0),
        ud(2 downto 0) => exOut(2 downto 0)
    );
end architecture ; -- arch



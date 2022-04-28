library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

-- I denne fil kaldes der to eightbitcomparator instances, 
-- som sættes sammen til et sixteenbitcomparator submodul

entity sixteenBitComparator is
  port (
    saveA16: in std_logic_vector (15 downto 0);
    saveB16: in std_logic_vector (15 downto 0);
    exIn16: in std_logic_vector (2 downto 0);
    exOut16: out std_logic_vector (2 downto 0)
    ) ;
end sixteenBitComparator ;

architecture arch of sixteenBitComparator is
    signal carryOver : std_logic_vector (2 downto 0);
    component eightBitComparator is
        port
        (
            saveA: in std_logic_vector (7 downto 0);
            saveB: in std_logic_vector (7 downto 0);
            exIn: in std_logic_vector (2 downto 0);
            exOut: out std_logic_vector (2 downto 0)
            );
            end component;
begin
    Comp1 : eightBitComparator port map ( 
        saveA(7 downto 0) => saveA16(7 downto 0),
        saveB(7 downto 0) => saveB16(7 downto 0),
        exIn(2 downto 0) => exIn16 (2 downto 0),
        exOut(2 downto 0) => carryOver(2 downto 0)
    );
    Comp2 : eightBitComparator port map (
        saveA(7 downto 0) => saveA16(15 downto 8),
        saveB(7 downto 0) => saveB16(15 downto 8),
        exIn(2 downto 0) => carryOver (2 downto 0),
        exOut(2 downto 0) => exOut16(2 downto 0)
    );
end architecture ; -- arch



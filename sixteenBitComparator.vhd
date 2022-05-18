library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

--! Submodul for sixteenbitcomparator opstilles.
entity sixteenBitComparator is
  port (
    saveA16: in std_logic_vector (15 downto 0);
    saveB16: in std_logic_vector (15 downto 0);
    exIn16: in std_logic_vector (2 downto 0);
    exOut16: out std_logic_vector (2 downto 0)
    ) ;
end sixteenBitComparator ;

architecture arch of sixteenBitComparator is
    signal carryOver : std_logic_vector (2 downto 0); --! Signal til at overførere resultatet fra den eightbit comparator, der compare de otte least significant bits videre til den eightbit comparator, som compare de otte most significant bits.
    --! Submodul for eightbitcomparator defineres.
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
    --! Første instance af eightbitcomparator kaldes.
    Comp1 : eightBitComparator port map ( 
        saveA(7 downto 0) => saveA16(7 downto 0),   --! De otte least significant bits fra A signalet forbindes.
        saveB(7 downto 0) => saveB16(7 downto 0),   --! De otte most significant bits fra B signalet forbindes.
        exIn(2 downto 0) => exIn16 (2 downto 0),    --! Resultat fra less significant bits forbindes.
        exOut(2 downto 0) => carryOver(2 downto 0)  --! Resultat for otte least significant bits comparator forbindes.
    );
    --! Anden instance af eightbitcomparator kaldes.
    Comp2 : eightBitComparator port map (
        saveA(7 downto 0) => saveA16(15 downto 8),  --! De otte least significant bits fra A signalet forbindes.
        saveB(7 downto 0) => saveB16(15 downto 8),  --! De otte most significant bits fra B signalet forbindes.
        exIn(2 downto 0) => carryOver (2 downto 0), --! Resultat fra otte least significant bits forbindes.
        exOut(2 downto 0) => exOut16(2 downto 0)    --! Resultat fra sixteenbit comparatoren forbindes.
    );
end architecture ; -- arch



library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

--! Submodul for sixteenbitcomparator består af 2 8-bit comparators der sættes sammen.
entity sixteenBitComparator is
  port (
    saveA16: in std_logic_vector (15 downto 0); --! Nye værdi til sammenligning
    saveB16: in std_logic_vector (15 downto 0); --! Værdi fra tidligere sammenligning
    exIn16: in std_logic_vector (2 downto 0);   --! "Carry" input fra tidligere comarator / starting conditions
    exOut16: out std_logic_vector (2 downto 0)  --! Resultat af sammenligningen 0 = (A > B), 1 = (A = B), 2 = (B > A)
    ) ;
end sixteenBitComparator ;

architecture arch of sixteenBitComparator is
    signal carryOver : std_logic_vector (2 downto 0); --! Signal til at overførere resultatet fra den eightbit comparator, der sammenligner de otte least significant bits videre til den eightbit comparator, som sammenligner de otte most significant bits.
    --! Submodul for eightbitcomparator.
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
    --! Første instance af eightbitcomparator.
    Comp1 : eightBitComparator port map ( 
        saveA(7 downto 0) => saveA16(7 downto 0),   --! De otte least significant bits fra A signalet.
        saveB(7 downto 0) => saveB16(7 downto 0),   --! De otte most significant bits fra B signalet.
        exIn(2 downto 0) => exIn16 (2 downto 0),    --! Resultat fra less significant bits.
        exOut(2 downto 0) => carryOver(2 downto 0)  --! Resultat for otte least significant bits comparator.
    );
    --! Anden instance af eightbitcomparator.
    Comp2 : eightBitComparator port map (
        saveA(7 downto 0) => saveA16(15 downto 8),  --! De otte least significant bits fra A signalet.
        saveB(7 downto 0) => saveB16(15 downto 8),  --! De otte most significant bits fra B signalet.
        exIn(2 downto 0) => carryOver (2 downto 0), --! Resultat fra otte least significant bits.
        exOut(2 downto 0) => exOut16(2 downto 0)    --! Resultat fra sixteenbit comparatoren.
    );
end architecture ; -- arch



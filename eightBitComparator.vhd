library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

--! Submodul for eightbitcomparator opstilles.
entity eightBitComparator is
  port (
    saveA: in std_logic_vector (7 downto 0);
    saveB: in std_logic_vector (7 downto 0);
    exIn: in std_logic_vector (2 downto 0);
    exOut: out std_logic_vector (2 downto 0)
    ) ;
end eightBitComparator ;

architecture arch of eightBitComparator is
    signal carryOver : std_logic_vector (2 downto 0); --! Signal til at overførere resultatet fra den fourbit comparator, der compare de fire least significant bits videre til den fourbit comparator, som compare de fire most significant bits.
    --! Submodul for fourbitcomparator defineres.
    component fourBitComparator is
        port
        (
            A: 		in std_logic_vector (3 downto 0);
            B: 		in std_logic_vector (3 downto 0);
            ind: 	in std_logic_vector (2 downto 0);
            ud: 	out std_logic_vector (2 downto 0)
            );
        end component;
begin
    --! Første instance af fourbitcomparator kaldes.
    Comp1 : fourBitComparator port map ( 
        A(3 downto 0) => saveA(3 downto 0),         --! De fire least significant bits fra A signalet forbindes.
        B(3 downto 0) => saveB(3 downto 0),         --! De fire least significant bits fra B signalet forbindes.
        ind(2 downto 0) => exIn (2 downto 0),       --! Resultat fra less significant bits forbindes.
        ud(2 downto 0) => carryOver(2 downto 0)     --! Resultat for fire least significant bits comparator forbindes.
    );
    --! Anden instance af fourbitcomparator kaldes.
    Comp2 : fourBitComparator port map (
        A(3 downto 0) => saveA(7 downto 4),         --! De fire most significant bits fra A signalet forbindes.
        B(3 downto 0) => saveB(7 downto 4),         --! De fire most significant bits fra B signalet forbindes.
        ind(2 downto 0) => carryOver (2 downto 0),  --! Resultat fra fire least significant bits forbindes.
        ud(2 downto 0) => exOut(2 downto 0)         --! Resultat fra eightbit comparatoren forbindes.
    );
end architecture ; -- arch



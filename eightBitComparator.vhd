library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

--! Submodul for eightbitcomparator består af 2 4-bit comparators der sættes sammen.
entity eightBitComparator is
  port (
    saveA: in std_logic_vector (7 downto 0);    --! Nye værdi til sammenligning
    saveB: in std_logic_vector (7 downto 0);    --! Værdi fra tidligere sammenligning
    exIn: in std_logic_vector (2 downto 0);     --! "Carry" input fra tidligere comarator / starting conditions
    exOut: out std_logic_vector (2 downto 0)    --! Resultat af sammenligningen 0 = (A > B), 1 = (A = B), 2 = (B > A)
    ) ;
end eightBitComparator ;

--! Arkitekturen for 8-bit komparatoren.
architecture arch of eightBitComparator is
    signal carryOver : std_logic_vector (2 downto 0); --! Signal til at overføre resultatet fra den fourbit comparator, der sammenligner de fire least significant bits videre til den fourbit comparator, som sammenligner de fire most significant bits.
    --! Submodul for fourbitcomparator.
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
    --! Første instance af fourbitcomparator.
    Comp1 : fourBitComparator port map ( 
        A(3 downto 0) => saveA(3 downto 0),         --! De fire least significant bits fra A signalet.
        B(3 downto 0) => saveB(3 downto 0),         --! De fire least significant bits fra B signalet.
        ind(2 downto 0) => exIn (2 downto 0),       --! Resultat fra less significant bits.
        ud(2 downto 0) => carryOver(2 downto 0)     --! Resultat for fire least significant bits comparator.
    );
    --! Anden instance af fourbitcomparator.
    Comp2 : fourBitComparator port map (
        A(3 downto 0) => saveA(7 downto 4),         --! De fire most significant bits fra A signalet.
        B(3 downto 0) => saveB(7 downto 4),         --! De fire most significant bits fra B signalet.
        ind(2 downto 0) => carryOver (2 downto 0),  --! Resultat fra fire least significant bits.
        ud(2 downto 0) => exOut(2 downto 0)         --! Resultat fra eightbit comparatoren.
    );
end architecture ; -- arch



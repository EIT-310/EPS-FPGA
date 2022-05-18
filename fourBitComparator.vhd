library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

--! Submodul for fourbitcomparator består udelukkende af statisk logik.
entity fourBitComparator is
	port
	(
    A: in std_logic_vector (3 downto 0); 	--! Nye værdi til sammenligning
    B: in std_logic_vector (3 downto 0);	--! Værdi fra tidligere sammenligning
    ind: in std_logic_vector (2 downto 0);	--! "Carry" input fra tidligere comarator / starting conditions
    ud: out std_logic_vector (2 downto 0)	--! Resultat af sammenligningen 0 = (A > B), 1 = (A = B), 2 = (B > A)
    );
end; 

--! Her laves logikken for Fourbitcomparatoren.
architecture struct of fourBitComparator is
    signal tmp: std_logic_vector (0 to 27);
	begin

		tmp(0) <= A(0) nand B(0);
		tmp(1) <= A(0) and tmp(0);
		tmp(2) <= B(0) and tmp(0);
		tmp(3) <= tmp(1) nor tmp(2);
	
		tmp(4) <= A(1) nand B(1);
		tmp(5) <= A(1) and tmp(4);
		tmp(6) <= B(1) and tmp(4);
		tmp(7) <= tmp(5) nor tmp(6);

		tmp(8) <= A(2) nand B(2);
		tmp(9) <= A(2) and tmp(8);
		tmp(10) <= B(2) and tmp(8);
		tmp(11) <= tmp(9) nor tmp(10);
	
		tmp(12) <= A(3) nand B(3);
		tmp(13) <= A(3) and tmp(12);
		tmp(14) <= B(3) and tmp(12);
		tmp(15) <= tmp(13) nor tmp(14);
	
		tmp(16) <= A(3) and tmp(12);
		tmp(17) <= A(2) and tmp(8) and tmp(15);
		tmp(18) <= A(1) and tmp(4) and tmp(15) and tmp(11);
		tmp(19) <= A(0) and tmp(0) and tmp(15) and tmp(11) and tmp(7);
		tmp(20) <= tmp(15) and tmp(7) and tmp(11) and tmp(3) and ind(2);
		tmp(21) <= tmp(15) and tmp(11) and tmp(7) and tmp(3) and ind(1);
		tmp(22) <= ind(1) and tmp(3) and tmp(7) and tmp(11) and tmp(15);
		tmp(23) <= ind(0) and tmp(3) and tmp(7) and tmp(11) and tmp(15);
		tmp(24) <= tmp(7) and tmp(11) and tmp(15) and tmp(0) and B(0);
		tmp(25) <= tmp(11) and tmp(15) and tmp(4) and B(1);
		tmp(26) <= tmp(15) and tmp(8) and B(2);
		tmp(27) <= tmp(12) and B(3);
	
		ud(2) <= not(tmp(27) or tmp(26) or tmp(25) or tmp(24) or tmp(23) or tmp(22));
	
		ud(1) <= tmp(15) and tmp(11) and ind(1) and tmp(7) and tmp(3);
	
		ud(0) <= not(tmp(21) or tmp(20) or tmp(19) or tmp(18) or tmp(17) or tmp(16));

 
		
	end;
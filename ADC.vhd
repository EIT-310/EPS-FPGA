library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
	
--! ADC submodul finder en given spænding ved at skabe en spænding ud fra et 8 bit
--! tal og en fysisk comparator, der viser om den produceret spænding er høje ellere
--! lavere end den der måles
entity adc is
    port (
    clk         : in std_logic;								--! Nedskaleret clock
    gpio1       : out std_logic_vector(7 downto 0);			--! Output til R2R-ladder
    result_sig_out  : out std_logic_vector (7 downto 0);	--! Endelige spænding fundet
    add_sub_sig : in std_logic								--! Input fra den fysiske komparator
  ) ;
end adc ; 

architecture arch of adc is
		
	type byte_arr is array (7 downto 0) of std_logic_vector (7 downto 0);
	signal dataa_arr: byte_arr;

    signal rotate 	: std_logic_vector(7 downto 0) := "10000000";	--! Hver cyklus bliver denne roteret højre om. Den agerer både som den
																	--! værdi der lægges til / trækkes fra, og de individuelle bits aktiverer
																	--! de respektive adder submoduler
	signal sel_sig 	: std_logic_vector(2 downto 0);					--! Input til sw multiplexer for at skrive adder outputs ud til R2R-ladder
	signal result_sig: std_logic_vector(7 downto 0);				--! Endelige spænding fundet, opdateres hver gang ADC har kørt en omgang

	--! Her bliver adder submodulet defineret.
    component adder is
		port (
		  clock : in std_logic;
		  add_sub : in std_logic;
		  dataa : in std_logic_vector (7 downto 0);
		  datab : in std_logic_vector (7 downto 0);
		  result: out std_logic_vector ( 7 downto 0)
		) ;
	end component;

begin
	--! Her sættes startværdien, så ADC'en altid starter i midten.
	dataa_arr(0)<= "10000000";

	--! Skriver resultatet af ADC målingen ud til output porten. 
	outputt : for i in 0 to 7 generate
		result_sig_out(i)<=dataa_arr(7)(i);
	end generate ; -- outputt

	--! Skriv multiplexer output til DAC.
	GPIO_write : for i in 0 to 7 generate
		gpio1(i) <= result_sig(7-i);
	end generate ; -- GPIO_write 
	
	--! Rotate data to be added/subtracted
	rotator : process(clk)
	begin
			if rising_edge(clk) then
				rotate <= rotate(0) & rotate(7 downto 1);
			end if ;
	end process ; -- rotator
	

	--! Generate 6 Addders
	adder_loop : for i in 0 to 6 generate
		adder_inst : adder port map (
			clock => rotate(6-i), 		--! Adderens clock er respektive bit i rotate
			add_sub => add_sub_sig,		--! Alle adders har input fra fysiske comparator
			dataa => dataa_arr(i),		--! add/sub til/fra tidligere adders resultat
			datab => rotate,			--! add/sub rotate til/fra dataa
			result => dataa_arr(i+1)	--! Skriv output til næste ADC input
		);
	end generate ; -- adder_loop
	
	--! Multiplexer for DAC
	with rotate select result_sig <=
		dataa_arr(0) when "10000000", -- Do nothing first cycle
		dataa_arr(0) when "01000000", -- Write prev. byte to DAC when add/sub  
		dataa_arr(1) when "00100000",
		dataa_arr(2) when "00010000", -- When DAC is      10000000 
		dataa_arr(3) when "00001000", -- we wanna add/sub 01000000
		dataa_arr(4) when "00000100", -- and so on
		dataa_arr(5) when "00000010",
		dataa_arr(6) when "00000001",
		dataa_arr(7) when others;     -- kommer ikke herned

end arch ; -- arch





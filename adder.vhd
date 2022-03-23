library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity adder is
  port (
    clock : in std_logic;
    glob_clock : in std_logic;
    clk2        : in std_logic;
    add_sub : in std_logic;
    add_sub_debug : out std_logic;
    dataa : in std_logic_vector (7 downto 0);
    datab : in std_logic_vector (7 downto 0);
    result: out std_logic_vector ( 7 downto 0)
  ) ;
end adder ; 

architecture arch of adder is

    signal u_dataa : unsigned (7 downto 0) := unsigned(dataa); 
    signal u_datab : unsigned (7 downto 0) := unsigned(datab); 
    signal u_result: unsigned (7 downto 0);
    signal add_sub_sig: std_logic;

begin
    
    get_add_bit : process( all )
    begin
        if (rising_edge(clk2)) then
            add_sub_sig <= add_sub;
        end if ;
    end process ; -- get_add_bit
           
            
    artih : process( all )
    begin
        if (falling_edge(glob_clock) and clock = '1' ) then
            -- add_sub_sig <= add_sub;
            add_sub_debug <= add_sub_sig;
            if add_sub_sig = '1' then
                u_result <= u_dataa + u_datab;
            else
                u_result <= u_dataa - u_datab;
            end if ;
        end if ;
    end process ; -- artih
    result <= std_logic_vector(u_result);
end architecture ;
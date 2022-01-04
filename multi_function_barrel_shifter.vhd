library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multi_function_barrel_shifter is
    port (
        lr : in std_logic;
        amt : in std_logic_vector(2 downto 0);
        d : out std_logic_vector(7 downto 0);
        q : out std_logic_vector(7 downto 0)
    );
end multi_function_barrel_shifter;

architecture arch of multi_function_barrel_shifter is
signal r_0, r_1, r_2 : std_logic_vector(7 downto 0);
signal l_0, l_1, l_2 : std_logic_vector(7 downto 0);
begin

r_0 <= d(0) & d(7 downto 1) when amt(0) = '1' else d;
r_1 <= r_0(1 downto 0) & r_0(7 downto 2) when amt(1) = '1' else r_0;
r_2 <= r_1(3 downto 0) & r_1(7 downto 4) when amt(2) = '1' else r_1;

l_0 <=  d(6 downto 0) & d(7) when amt(0) = '1' else d;
l_1 <= l_0(5 downto 0) & l_0(7 downto 6) when amt(1) = '1' else l_0;
l_2 <= l_1(3 downto 0) & l_1(7 downto 4) when amt(2) = '1' else l_1;

q <= l_2 when lr = '0' else r_2;

end architecture;
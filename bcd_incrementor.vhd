library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_incrementor is
    port (
        d : in std_logic_vector(11 downto 0);
        q : out std_logic_vector(11 downto 0)
    );
end bcd_incrementor;

architecture arch of bcd_incrementor is
signal d_0, d_1, d_2 : std_logic_vector(3 downto 0);
begin
d_0 <= (others => '0') when d(3 downto 0) = "1001" else std_logic_vector(unsigned(d(3 downto 0)) + 1);

d_1 <= (others => '0') when d(7 downto 4) = "1001" and d(3 downto 0) = "1001" else 
       std_logic_vector(unsigned(d(7 downto 4)) + 1) when d(3 downto 0) = "1001" else
       d(7 downto 4);
       
d_2 <= (others => '0') when d(11 downto 8) = "1001" and d(7 downto 4) = "1001" and d(3 downto 0) = "1001" else 
       std_logic_vector(unsigned(d(11 downto 8)) + 1) when d(7 downto 4) = "1001" and d(3 downto 0) = "1001" else
       d(11 downto 8);

q <= d_2 & d_1 & d_0;

end architecture;
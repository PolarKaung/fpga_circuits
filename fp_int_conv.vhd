library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_int_conv is
    port (
        fp : in std_logic_vector(12 downto 0);
        uf, ovf : out std_logic;
        signed_int : out std_logic_vector(7 downto 0)
    );
end fp_int_conv;
-- Dumbass :")
architecture arch of fp_int_conv is
signal exp : unsigned(3 downto 0) := (others => '0');
signal sign : std_logic := '0';
signal frac : unsigned(7 downto 0) := (others => '0');
signal int_reg : unsigned(7 downto 0) := (others => '0');
begin
sign <= fp(12);
exp <= unsigned(fp(11 downto 8));
frac <= unsigned(fp(7 downto 0));

int_reg <= frac when exp >= "1000" else 
           "0000000" & frac(7) when exp = "0001" else
           "000000" & frac(7 downto 6) when exp = "0010" else
           "00000" & frac(7 downto 5) when exp = "0011" else
           "0000" & frac(7 downto 4) when exp = "0100" else
           "000" & frac(7 downto 3) when exp = "0101" else
           "00" & frac(7 downto 2) when exp = "0110" else
           "0" & frac(7 downto 1) when exp = "0111" else
           "00000000";

signed_int <= std_logic_vector(int_reg) when sign = '0' else std_logic_vector(unsigned(not int_reg) + 1);
uf <= '1' when sign =  '1' and (exp > 8 or signed_int < "10000000") else '0';
ovf <= '1' when sign = '0' and (exp > 8 or signed_int > "01111111") else '0';

-- -128 -- +127 => 1 10000000 8 => 0 01111111 6

-- 100.5 => 0 5 11001001 

-- 1 00000001 8 => 11111111 => -1
-- 1 00000010 8 => 11111110 => -2
-- 1 00000011 8 => 11111101 => -3
-- 1 10000000 8 => 10000000 => -128
-- 1 10000001 8 => 01111111 => -129 
-- 01111111 + 1 => 10000000
-- 11111111
-- 01111111 => pos
-- 10000001 => neg

-- 10000000 => 11111111 => neg_range = 10000000 =>
-- 00000000 => 01111111 => pos_range

-- 00000001 => +1
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_gt is
    port (
        fp_a, fp_b : in std_logic_vector(12 downto 0);
        gt : out std_logic
    );
end floating_point_gt;

architecture arch of floating_point_gt is
signal exp_a, exp_b : std_logic_vector(3 downto 0) := (others => '0');
signal sign_a, sign_b, gt_inv : std_logic := '0';
signal frac_a, frac_b : std_logic_vector(7 downto 0) := (others => '0');
begin
sign_a <= fp_a(12);
sign_b <= fp_b(12);

exp_a <= fp_a(11 downto 8);
exp_b <= fp_b(11 downto 8);

frac_a <= fp_a(7 downto 0);
frac_b <= fp_b(7 downto 0);

gt_inv <= '1' when (sign_a > sign_b) or ((sign_a = sign_b) and (exp_a & frac_a) < (exp_b & frac_b)) else
	  '0';
gt <= not gt_inv;
      
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_priority_encoder is
    port (
        req : in std_logic_vector(11 downto 0);
        first, second : out std_logic_vector(3 downto 0)
    );
end dual_priority_encoder;

architecture arch of dual_priority_encoder is
signal mask, sec_req : std_logic_vector(11 downto 0);
begin
    first <= "1100" when req(11) = '1' else
             "1011" when req(10) = '1' else
             "1010" when req(9) = '1' else
             "1001" when req(8) = '1' else
             "1000" when req(7) = '1' else
             "0111" when req(6) = '1' else
             "0110" when req(5) = '1' else
             "0101" when req(4) = '1' else
             "0100" when req(3) = '1' else
             "0011" when req(2) = '1' else
             "0010" when req(1) = '1' else
             "0001" when req(0) = '1' else
             "0000";

    mask <= (11 downto 1 => '0') & '1' when first = "0001" else
            (11 downto 2 => '0') & '1' & '0' when first = "0010" else
            (11 downto 3 => '0') & '1' & (1 downto 0 => '0') when first = "0011" else
            (11 downto 4 => '0') & '1' & (2 downto 0 => '0') when first = "0100" else
            (11 downto 5 => '0') & '1' & (3 downto 0 => '0') when first = "0101" else
            (11 downto 6 => '0') & '1' & (4 downto 0 => '0') when first = "0110" else
            (11 downto 7 => '0') & '1' & (5 downto 0 => '0') when first = "0111" else
            (11 downto 8 => '0') & '1' & (6 downto 0 => '0') when first = "1000" else
            (11 downto 9 => '0') & '1' & (7 downto 0 => '0') when first = "1001" else
            (11 downto 10 => '0') & '1' & (8 downto 0 => '0') when first = "1010" else
            '0' & '1' & (9 downto 0 => '0') when first = "1011" else
            '1' & (10 downto 0 => '0') when first = "1100" else
            (others => '0');
            
    sec_req <= req AND not mask;
    second <= "1100" when sec_req(11) = '1' else
              "1011" when sec_req(10) = '1' else
              "1010" when sec_req(9) = '1' else
              "1001" when sec_req(8) = '1' else
              "1000" when sec_req(7) = '1' else
              "0111" when sec_req(6) = '1' else
              "0110" when sec_req(5) = '1' else
              "0101" when sec_req(4) = '1' else
              "0100" when sec_req(3) = '1' else
              "0011" when sec_req(2) = '1' else
              "0010" when sec_req(1) = '1' else
              "0001" when sec_req(0) = '1' else
              "0000";

end architecture;
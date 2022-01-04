library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity int_fp_conv is
    port (
        int : in std_logic_vector(7 downto 0);
        fp : out std_logic_vector(12 downto 0)
    );
end int_fp_conv;

architecture arch of int_fp_conv is
signal sign : std_logic := '0';
signal exp : std_logic_vector(3 downto 0) := (others => '0');
signal frac, inter_state : std_logic_vector(7 downto 0) := (others => '0');
signal int_reg  : unsigned(7 downto 0) := (others => '0');
signal leading_zeros : unsigned(3 downto 0) := (others => '0');
begin

sign <= '1' when int(7) = '1' else '0';

inter_state <= int when sign = '0' else not std_logic_vector(unsigned(int)-1);

leading_zeros <= "0000" when inter_state(7) = '1' else
                 "0001" when inter_state(6) = '1' else
                 "0010" when inter_state(5) = '1' else
                 "0011" when inter_state(4) = '1' else
                 "0100" when inter_state(3) = '1' else
                 "0101" when inter_state(2) = '1' else
                 "0110" when inter_state(1) = '1' else
                 "0111" when inter_state(0) = '1' else
                 "1000";

frac <= inter_state when leading_zeros = "0000" else
  inter_state(6 downto 0) &      '0'   when leading_zeros = "0001" else
   inter_state(5 downto 0) &     "00"   when leading_zeros = "0010" else
    inter_state(4 downto 0) &    "000"   when leading_zeros = "0011" else
     inter_state(3 downto 0) &   "0000"   when leading_zeros = "0100" else
      inter_state(2 downto 0) &  "00000"   when leading_zeros = "0101" else
       inter_state(1 downto 0) & "000000"   when leading_zeros = "0110" else
        inter_state(0) & "0000000"  when leading_zeros = "0111" else
        "00000000";

exp <= std_logic_vector("1000" - leading_zeros);

fp <= sign & exp & frac;

end architecture;
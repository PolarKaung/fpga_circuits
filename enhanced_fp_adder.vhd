library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enhanced_fp_adder is
    port (
        fp_a, fp_b : in std_logic_vector(12 downto 0);
        fp_out : out std_logic_vector(12 downto 0)
    );
end enhanced_fp_adder;

architecture arch of enhanced_fp_adder is
    signal exp_a, exp_b, exp_g, exp_s, exp_norm : unsigned(3 downto 0) := (others => '0');
    signal frac_a, frac_b, frac_g, frac_s, frac_align, frac_norm, buffer_r, frac_s_round: unsigned(7 downto 0) := (others => '0');
    signal frac_unnorm : unsigned(8 downto 0) := (others => '0');
    signal sign_a, sign_b, sign_out, guard, round_r : std_logic := '0';
    signal exp_diff : unsigned(3 downto 0) := (others => '0');
    signal leading_zeros : unsigned(3 downto 0) := (others => '0');
    signal sticky : unsigned(5 downto 0) := (others => '0');
begin
    sign_a <= fp_a(12);
    exp_a <= unsigned(fp_a(11 downto 8));
    frac_a <= unsigned(fp_a(7 downto 0));
    sign_b <= fp_b(12);
    exp_b <= unsigned(fp_b(11 downto 8));
    frac_b <= unsigned(fp_b(7 downto 0));

    -- sorting
    SORT_PROC : process(sign_a, sign_b, exp_a, exp_b, frac_a, frac_b)
    begin
        if (exp_a&frac_a > exp_b&frac_b) then
            exp_g <= exp_a;
            exp_s <= exp_b;
            frac_g <= frac_a;
            frac_s <= frac_b;
            sign_out <= sign_a;
	else
	    exp_g <= exp_b;
            exp_s <= exp_a;
            frac_g <= frac_b;
            frac_s <= frac_a;
            sign_out <= sign_b;
        end if;
    end process;

    -- align
    exp_diff <= exp_g - exp_s;
    frac_align <= frac_s when exp_diff = "0000" else
                           '0' & frac_s(7 downto 1) when exp_diff = "0001" else
                           "00" & frac_s(7 downto 2) when exp_diff = "0010" else
                           "000" & frac_s(7 downto 3) when exp_diff = "0011" else
                           "0000" & frac_s(7 downto 4) when exp_diff = "0100" else
                           "00000" & frac_s(7 downto 5) when exp_diff = "0101" else
                           "000000" & frac_s(7 downto 6) when exp_diff = "0110" else
                           "0000000" & frac_s(7) when exp_diff = "0111" else
                           "00000000";
    buffer_r <= "00000000" when exp_diff = "0000" else
                           frac_s(0) & "0000000" when exp_diff = "0001" else
                           frac_s(1 downto 0) & "000000" when exp_diff = "0010" else
                           frac_s(2 downto 0) & "00000" when exp_diff = "0011" else
                           frac_s(3 downto 0) & "0000" when exp_diff = "0100" else
                           frac_s(4 downto 0) & "000" when exp_diff = "0101" else
                           frac_s(5 downto 0) & "00" when exp_diff = "0110" else
                           frac_s(6 downto 0) & "0" when exp_diff = "0111" else
                           frac_s(7 downto 0) when exp_diff =  "1000" else
                           "00000000";
    guard <= buffer_r(7);
    round_r <= buffer_r(6);
    sticky <= unsigned(buffer_r(5 downto 0));

    frac_s_round <= frac_align when guard = '0' else
                              frac_align + 1 when frac_align(0) = '1' and guard = '1' and round_r = '0' and sticky = "000000" else
                              frac_align when frac_align(0) = '0' and guard = '1' and round_r = '0' and sticky = "000000" else
                              frac_align + 1 when guard = '1' and (round_r/= '0' or sticky /= "000000");
                           -- calculate
    frac_unnorm <= ('0' & frac_g) + ('0' & frac_s_round) when sign_a = sign_b else ('0' & frac_g) - ('0' & frac_s_round);

    -- normalize
    leading_zeros <= "0000" when frac_unnorm(7) = '1' else
                                 "0001" when frac_unnorm(6) = '1' else
                                 "0010" when frac_unnorm(5) = '1' else
                                 "0011" when frac_unnorm(4) = '1' else
                                 "0100" when frac_unnorm(3) = '1' else
                                 "0101" when frac_unnorm(2) = '1' else
                                 "0110" when frac_unnorm(1) = '1' else
                                 "0111" when frac_unnorm(0) = '1' else
				 "1000";
                            
    NORMALIZE_PROC : process(frac_unnorm, leading_zeros, exp_g)
    begin
        if (frac_unnorm(8) = '1') then
            frac_norm <= frac_unnorm(8 downto 1) when frac_unnorm(0) = '0' else 
                                  frac_unnorm(8 downto 1) when frac_unnorm(1) = '0' else 
                                  frac_unnorm(8 downto 1) + 1;
            exp_norm <= exp_g + 1;
        elsif (leading_zeros > exp_g) then
            frac_norm <= (others => '0');
            exp_norm <= (others => '0');
        else
        -- 0 00011111
	    frac_norm <= frac_unnorm(7 downto 0) when leading_zeros = "0000" else
			 frac_unnorm(6 downto 0) & '0' when leading_zeros = "0001" else
			 frac_unnorm(5 downto 0) & "00" when leading_zeros = "0010" else
			 frac_unnorm(4 downto 0) & "000" when leading_zeros = "0011" else
			 frac_unnorm(3 downto 0) & "0000" when leading_zeros = "0100" else
			 frac_unnorm(2 downto 0) & "00000" when leading_zeros = "0101" else
			 frac_unnorm(1 downto 0) & "000000" when leading_zeros = "0110" else
			 frac_unnorm(0) & "0000000" when leading_zeros = "0111" else
			 "00000000";
            exp_norm <= exp_g - leading_zeros;
        end if;
    end process;

    -- output
    fp_out <= sign_out & std_logic_vector(exp_norm) & std_logic_vector(frac_norm);
end architecture;
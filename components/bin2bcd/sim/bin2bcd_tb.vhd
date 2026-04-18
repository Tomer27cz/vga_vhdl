library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity bin2bcd_tb is
end entity;

architecture tb of bin2bcd_tb is
    signal bin        : std_logic_vector(7 downto 0) := (others => '0');

    signal hundreds   : std_logic_vector(3 downto 0);
    signal tens       : std_logic_vector(3 downto 0);
    signal ones       : std_logic_vector(3 downto 0);

    signal TbSimEnded : std_logic := '0';

    component bin2bcd
        port (
            bin      : in  std_logic_vector(7 downto 0);
            hundreds : out std_logic_vector(3 downto 0);
            tens     : out std_logic_vector(3 downto 0);
            ones     : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    dut_bin2bcd : bin2bcd
        port map (
            bin      => bin,
            hundreds => hundreds,
            tens     => tens,
            ones     => ones
        );

    -- Stimulus process
    p_stim : process
        -- Helper procedure to apply an integer and check the BCD output
        procedure check_conversion(
            val      : integer;
            exp_h    : std_logic_vector(3 downto 0);
            exp_t    : std_logic_vector(3 downto 0);
            exp_o    : std_logic_vector(3 downto 0);
            msg      : string
            ) is
        begin
            bin <= std_logic_vector(to_unsigned(val, 8));

            wait for 10 ns;

            assert (hundreds = exp_h and tens = exp_t and ones = exp_o)
                report "Error: " & msg
                severity error;
        end procedure;

    begin
        report "Starting simulation: Binary to BCD Converter";

        report "Zero";
        check_conversion(0,   "0000", "0000", "0000", "0 did not convert correctly");

        report "Single Digits";
        check_conversion(5,   "0000", "0000", "0101", "5 did not convert correctly");
        check_conversion(9,   "0000", "0000", "1001", "9 did not convert correctly");

        report "Two Digits";
        check_conversion(10,  "0000", "0001", "0000", "10 did not convert correctly");
        check_conversion(42,  "0000", "0100", "0010", "42 did not convert correctly");
        check_conversion(99,  "0000", "1001", "1001", "99 did not convert correctly");

        report "Three Digits (Max values)";
        check_conversion(100, "0001", "0000", "0000", "100 did not convert correctly");
        check_conversion(123, "0001", "0010", "0011", "123 did not convert correctly");
        check_conversion(255, "0010", "0101", "0101", "255 did not convert correctly");

        report "Simulation finished without errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
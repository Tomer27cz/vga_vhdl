library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity digit_draw_tb is
end entity;

architecture tb of digit_draw_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal clk        : std_logic := '1';
    signal rst        : std_logic;
    signal ce         : std_logic := '1';
    signal h_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal v_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal video_on   : std_logic := '0';

    signal bcd_val    : std_logic_vector(3 downto 0) := (others => '0');
    signal x_pos      : std_logic_vector(9 downto 0) := (others => '0');
    signal y_pos      : std_logic_vector(9 downto 0) := (others => '0');

    signal red        : std_logic_vector(3 downto 0);
    signal green      : std_logic_vector(3 downto 0);
    signal blue       : std_logic_vector(3 downto 0);

    signal TbSimEnded : std_logic := '0';

    component digit_draw
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            ce        : in  std_logic;
            h_count   : in  std_logic_vector(9 downto 0);
            v_count   : in  std_logic_vector(9 downto 0);
            video_on  : in  std_logic;
            bcd_val   : in  std_logic_vector(3 downto 0);
            x_pos     : in  std_logic_vector(9 downto 0);
            y_pos     : in  std_logic_vector(9 downto 0);
            red       : out std_logic_vector(3 downto 0);
            green     : out std_logic_vector(3 downto 0);
            blue      : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    dut_digit : digit_draw
        port map (
            clk       => clk,
            rst       => rst,
            ce        => ce,
            h_count   => h_count,
            v_count   => v_count,
            video_on  => video_on,
            bcd_val   => bcd_val,
            x_pos     => x_pos,
            y_pos     => y_pos,
            red       => red,
            green     => green,
            blue      => blue
        );

    clk <= not clk after CLK_PERIOD/2 when TbSimEnded /= '1' else '0';

    p_stim : process
        procedure check_pixel(
            h       : integer;
            v       : integer;
            exp_r   : std_logic_vector(3 downto 0);
            exp_g   : std_logic_vector(3 downto 0);
            exp_b   : std_logic_vector(3 downto 0);
            msg     : string
            ) is
        begin
            h_count <= std_logic_vector(to_unsigned(h, 10));
            v_count <= std_logic_vector(to_unsigned(v, 10));

            wait until rising_edge(clk);
            wait for 1 ns;
            assert (red = exp_r and green = exp_g and blue = exp_b)
                report "Error: " & msg
                severity error;
        end procedure;

    begin
        report "Starting simulation: Asserting reset";
        rst <= '1';
        video_on <= '0';
        ce <= '1';

        -- Place digit '0' at (100, 100)
        bcd_val <= "0000";
        x_pos   <= std_logic_vector(to_unsigned(100, 10));
        y_pos   <= std_logic_vector(to_unsigned(100, 10));

        wait for CLK_PERIOD * 10;
        rst <= '0';
        report "Reset released";
        wait for CLK_PERIOD * 2;

        video_on <= '1';
        wait for CLK_PERIOD;

        report "Background render outside bounding box";
        check_pixel(50, 50, "0000", "0000", "0000", "Pixel well outside bounding box should be black");

        report "Digit transparent background render";
        check_pixel(100, 100, "0000", "0000", "0000", "Top-left pixel of '0' background should be black");

        report "Digit foreground render";
        check_pixel(104, 100, "1111", "1111", "1111", "Top edge pixel of '0' should be white");

        report "Digit foreground side render";
        check_pixel(100, 106, "1111", "1111", "1111", "Side edge pixel of '0' should be white");

        report "Invalid BCD check";
        bcd_val <= "1010";
        wait for CLK_PERIOD;
        check_pixel(104, 100, "1111", "1111", "1111", "Invalid BCD should fallback to '0' and render white here");

        report "Blanking";
        video_on <= '0';
        wait for CLK_PERIOD;
        check_pixel(104, 100, "0000", "0000", "0000", "Output must be black when video_on is low");

        report "Simulation finished successfully without logic errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
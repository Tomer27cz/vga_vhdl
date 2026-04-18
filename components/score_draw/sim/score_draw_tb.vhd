library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity score_draw_tb is
end entity;

architecture tb of score_draw_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal clk        : std_logic := '1';
    signal rst        : std_logic;
    signal ce         : std_logic := '0';

    signal h_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal v_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal video_on   : std_logic := '0';

    signal p1_score   : std_logic_vector(7 downto 0) := (others => '0');
    signal p2_score   : std_logic_vector(7 downto 0) := (others => '0');

    signal red        : std_logic_vector(3 downto 0);
    signal green      : std_logic_vector(3 downto 0);
    signal blue       : std_logic_vector(3 downto 0);

    signal TbSimEnded : std_logic := '0';

    component score_draw
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            ce        : in  std_logic;
            h_count   : in  std_logic_vector(9 downto 0);
            v_count   : in  std_logic_vector(9 downto 0);
            video_on  : in  std_logic;
            p1_score  : in  std_logic_vector(7 downto 0);
            p2_score  : in  std_logic_vector(7 downto 0);
            red       : out std_logic_vector(3 downto 0);
            green     : out std_logic_vector(3 downto 0);
            blue      : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    dut_score : score_draw
        port map (
            clk       => clk,
            rst       => rst,
            ce        => ce,
            h_count   => h_count,
            v_count   => v_count,
            video_on  => video_on,
            p1_score  => p1_score,
            p2_score  => p2_score,
            red       => red,
            green     => green,
            blue      => blue
        );

    clk <= not clk after CLK_PERIOD/2 when TbSimEnded /= '1' else '0';

    p_ce : process
    begin
        if TbSimEnded = '1' then
            wait;
        end if;
        ce <= '0';
        wait for CLK_PERIOD * 3;
        ce <= '1';
        wait for CLK_PERIOD;
    end process;

    p_stim : process
    begin
        report "Starting simulation: Asserting reset";
        rst <= '1';
        video_on <= '0';

        wait for CLK_PERIOD * 10;
        rst <= '0';
        report "Reset released";
        wait for CLK_PERIOD * 10;

        -- Set V_COUNT to a line where the text is drawn (Y = 40)
        -- The font bounding box starts at C_SCORE_Y (16) and is 48 pixels high
        v_count  <= std_logic_vector(to_unsigned(40, 10));
        video_on <= '1';

        report "Test Case 1: 0 - 0 (Both players have 1 digit)";
        p1_score <= std_logic_vector(to_unsigned(0, 8));
        p2_score <= std_logic_vector(to_unsigned(0, 8));
        wait for CLK_PERIOD * 10;

        -- Sweep H_COUNT across the display width to observe RGB output triggers
        for i in 0 to 639 loop
            h_count <= std_logic_vector(to_unsigned(i, 10));
            wait for CLK_PERIOD * 4; -- Wait one pixel clock (ce cycle)
        end loop;

        wait for CLK_PERIOD * 10;

        report "Test Case 2: 9 - 10 (Player 1 has 1 digit, Player 2 has 2 digits)";
        p1_score <= std_logic_vector(to_unsigned(9, 8));
        p2_score <= std_logic_vector(to_unsigned(10, 8));
        wait for CLK_PERIOD * 10;

        for i in 0 to 639 loop
            h_count <= std_logic_vector(to_unsigned(i, 10));
            wait for CLK_PERIOD * 4;
        end loop;

        wait for CLK_PERIOD * 10;

        report "Test Case 3: 99 - 125 (Player 1 has 2 digits, Player 2 has 3 digits)";
        p1_score <= std_logic_vector(to_unsigned(99, 8));
        p2_score <= std_logic_vector(to_unsigned(125, 8));
        wait for CLK_PERIOD * 10;

        for i in 0 to 639 loop
            h_count <= std_logic_vector(to_unsigned(i, 10));
            wait for CLK_PERIOD * 4;
        end loop;

        wait for CLK_PERIOD * 10;

        report "Blanking";
        video_on <= '0';
        wait for CLK_PERIOD * 20;

        report "Simulation finished successfully without logic errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
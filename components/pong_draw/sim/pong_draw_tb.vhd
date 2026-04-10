library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_draw_tb is
end entity;

architecture tb of pong_draw_tb is
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz system clock

    signal clk        : std_logic := '1';
    signal rst        : std_logic;
    signal ce         : std_logic := '1';

    signal h_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal v_count    : std_logic_vector(9 downto 0) := (others => '0');
    signal video_on   : std_logic := '0';

    signal paddle1_y  : std_logic_vector(9 downto 0) := (others => '0');
    signal paddle2_y  : std_logic_vector(9 downto 0) := (others => '0');
    signal ball_x     : std_logic_vector(9 downto 0) := (others => '0');
    signal ball_y     : std_logic_vector(9 downto 0) := (others => '0');

    signal red        : std_logic_vector(3 downto 0);
    signal green      : std_logic_vector(3 downto 0);
    signal blue       : std_logic_vector(3 downto 0);

    signal TbSimEnded : std_logic := '0';

    component pong_draw
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            ce        : in  std_logic;
            h_count   : in  std_logic_vector(9 downto 0);
            v_count   : in  std_logic_vector(9 downto 0);
            video_on  : in  std_logic;
            paddle1_y : in  std_logic_vector(9 downto 0);
            paddle2_y : in  std_logic_vector(9 downto 0);
            ball_x    : in  std_logic_vector(9 downto 0);
            ball_y    : in  std_logic_vector(9 downto 0);
            red       : out std_logic_vector(3 downto 0);
            green     : out std_logic_vector(3 downto 0);
            blue      : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    dut_draw : pong_draw
        port map (
            clk       => clk,
            rst       => rst,
            ce        => ce,
            h_count   => h_count,
            v_count   => v_count,
            video_on  => video_on,
            paddle1_y => paddle1_y,
            paddle2_y => paddle2_y,
            ball_x    => ball_x,
            ball_y    => ball_y,
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

        paddle1_y <= std_logic_vector(to_unsigned(100, 10));
        paddle2_y <= std_logic_vector(to_unsigned(200, 10));
        ball_x    <= std_logic_vector(to_unsigned(300, 10));
        ball_y    <= std_logic_vector(to_unsigned(150, 10));

        wait for CLK_PERIOD * 10;

        rst <= '0';
        report "Reset released";
        wait for CLK_PERIOD * 2;

        video_on <= '1';
        wait for CLK_PERIOD;

        report "Background render";
        check_pixel(0, 0, "0000", "0000", "0000", "Background should be black");

        report "Center Line render";
        -- H_DISPLAY / 2 = 320 -- visible where (v_pos mod 16) < 8.
        check_pixel(320, 5,  "0100", "0100", "0100", "Center line dash should be grey");
        check_pixel(320, 10, "0000", "0000", "0000", "Center line gap should be black");

        report "Paddle render";
        -- X=20 to 30, Y=100 to 160
        check_pixel(25,  110, "1111", "1111", "1111", "Paddle 1 should be white");
        -- X=610 to 620, Y=200 to 260
        check_pixel(615, 210, "1111", "1111", "1111", "Paddle 2 should be white");

        report "Ball render";
        -- X=300 to 310, Y=150 to 160
        check_pixel(305, 155, "1111", "1111", "0000", "Ball should be yellow");

        report "Overlap Ball and Line";
        ball_x <= std_logic_vector(to_unsigned(318, 10));
        ball_y <= std_logic_vector(to_unsigned(3, 10));
        wait for CLK_PERIOD;
        check_pixel(320, 5, "1111", "1111", "0000", "Ball should render on top of the center line");

        report "Blanking";
        video_on <= '0';
        wait for CLK_PERIOD;
        check_pixel(320, 5, "0000", "0000", "0000", "Output must be black when video_on is low");

        report "Simulation finished successfully without logic errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
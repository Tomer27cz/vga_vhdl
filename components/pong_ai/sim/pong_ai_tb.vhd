library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_ai_tb is
end entity;

architecture tb of pong_ai_tb is
    -- 100 MHz system clock
    constant CLK_PERIOD : time := 10 ns;

    signal clk          : std_logic := '1';
    signal rst          : std_logic;
    signal ce_60hz      : std_logic := '0';

    signal ball_y       : std_logic_vector(9 downto 0) := (others => '0');
    signal paddle_y     : std_logic_vector(9 downto 0) := (others => '0');

    signal paddle_up    : std_logic;
    signal paddle_down  : std_logic;

    signal TbSimEnded   : std_logic := '0';

    component pong_ai
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            ce_60hz     : in  std_logic;
            ball_y      : in  std_logic_vector(9 downto 0);
            paddle_y    : in  std_logic_vector(9 downto 0);
            paddle_up   : out std_logic;
            paddle_down : out std_logic
        );
    end component;

begin

    dut_ai : pong_ai
        port map (
            clk         => clk,
            rst         => rst,
            ce_60hz     => ce_60hz,
            ball_y      => ball_y,
            paddle_y    => paddle_y,
            paddle_up   => paddle_up,
            paddle_down => paddle_down
        );

    clk <= not clk after CLK_PERIOD/2 when TbSimEnded /= '1' else '0';

    p_ce : process
    begin
        if TbSimEnded = '1' then
            wait;
        end if;
        ce_60hz <= '0';
        wait for CLK_PERIOD * 9;
        ce_60hz <= '1';
        wait for CLK_PERIOD;
    end process;

    p_stim : process
        procedure wait_frames(frames : integer) is
        begin
            for i in 1 to frames loop
                wait until rising_edge(clk) and ce_60hz = '1';
            end loop;
        end procedure;

    begin
        report "Starting simulation: Asserting reset";
        rst <= '1';
        wait for CLK_PERIOD * 10;

        rst <= '0';
        report "Reset released";

        wait_frames(1);

        ----------------------------------------------------------------
        -- Ball is above the paddle
        ----------------------------------------------------------------
        report "TEST 1: Checking upward tracking";
        -- Paddle Y = 200 -> Center = 230
        -- Ball Y = 100 -> Center = 105
        paddle_y <= std_logic_vector(to_unsigned(200, 10));
        ball_y   <= std_logic_vector(to_signed(100, 10));

        wait_frames(2);

        assert paddle_up = '1' and paddle_down = '0'
            report "Error: AI should move paddle up."
            severity error;

        ----------------------------------------------------------------
        -- Ball is below the paddle
        ----------------------------------------------------------------
        report "TEST 2: Checking downward tracking";
        -- Paddle Y = 200 -> Center = 230
        -- Ball Y = 300 -> Center = 305
        paddle_y <= std_logic_vector(to_unsigned(200, 10));
        ball_y   <= std_logic_vector(to_signed(300, 10));

        wait_frames(2);

        assert paddle_up = '0' and paddle_down = '1'
            report "Error: AI should move paddle down."
            severity error;

        ----------------------------------------------------------------
        -- Ball is lined up (inside deadzone)
        ----------------------------------------------------------------
        report "TEST 3: Checking deadzone";
        -- Paddle Y = 200 -> Center = 230
        -- Ball Y = 225 -> Center = 230
        paddle_y <= std_logic_vector(to_unsigned(200, 10));
        ball_y   <= std_logic_vector(to_signed(225, 10));

        wait_frames(2);

        assert paddle_up = '0' and paddle_down = '0'
            report "Error: AI should not move when ball is within deadzone."
            severity error;

        report "Simulation finished successfully without logic errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
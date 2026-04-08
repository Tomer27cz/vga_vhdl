library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.const_pkg.all; -- Imported to use V_DISPLAY, C_PADDLE_HEIGHT, etc.

entity pong_physics_tb is
end entity;

architecture tb of pong_physics_tb is
    -- 100 MHz system clock
    constant CLK_PERIOD : time := 10 ns;

    signal clk        : std_logic := '1';
    signal rst        : std_logic;
    signal ce_60hz    : std_logic := '0';

    -- Player Inputs
    signal p1_up      : std_logic := '0';
    signal p1_down    : std_logic := '0';
    signal p2_up      : std_logic := '0';
    signal p2_down    : std_logic := '0';

    -- Outputs
    signal paddle1_y  : std_logic_vector(9 downto 0);
    signal paddle2_y  : std_logic_vector(9 downto 0);
    signal ball_x     : std_logic_vector(9 downto 0);
    signal ball_y     : std_logic_vector(9 downto 0);
    signal score_p1   : std_logic_vector(7 downto 0);
    signal score_p2   : std_logic_vector(7 downto 0);

    signal TbSimEnded : std_logic := '0';

    component pong_physics
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            ce_60hz   : in  std_logic;
            p1_up     : in  std_logic;
            p1_down   : in  std_logic;
            p2_up     : in  std_logic;
            p2_down   : in  std_logic;
            paddle1_y : out std_logic_vector(9 downto 0);
            paddle2_y : out std_logic_vector(9 downto 0);
            ball_x    : out std_logic_vector(9 downto 0);
            ball_y    : out std_logic_vector(9 downto 0);
            score_p1  : out std_logic_vector(7 downto 0);
            score_p2  : out std_logic_vector(7 downto 0)
        );
    end component;

begin

    dut_physics : pong_physics
        port map (
            clk       => clk,
            rst       => rst,
            ce_60hz   => ce_60hz,
            p1_up     => p1_up,
            p1_down   => p1_down,
            p2_up     => p2_up,
            p2_down   => p2_down,
            paddle1_y => paddle1_y,
            paddle2_y => paddle2_y,
            ball_x    => ball_x,
            ball_y    => ball_y,
            score_p1  => score_p1,
            score_p2  => score_p2
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

    -- Stimulus process
    p_stim : process
        -- Helper procedure to wait for N physics frames
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

        report "TEST 1: Checking Initial Positions";
        assert to_integer(unsigned(paddle1_y)) = (V_DISPLAY / 2) - (C_PADDLE_HEIGHT / 2)
            report "Error: Paddle 1 initial Y is incorrect." severity error;
        assert to_integer(unsigned(ball_x)) = H_DISPLAY / 2
            report "Error: Ball initial X is incorrect." severity error;
        assert to_integer(unsigned(score_p1)) = 0 and to_integer(unsigned(score_p2)) = 0
            report "Error: Initial scores are not 0." severity error;

        report "TEST 2: Moving Paddles";
        p1_up <= '1';
        p2_down <= '1';

        wait_frames(10);

        p1_up <= '0';
        p2_down <= '0';

        assert to_integer(unsigned(paddle1_y)) < (V_DISPLAY / 2) - (C_PADDLE_HEIGHT / 2)
            report "Error: Paddle 1 did not move up." severity error;
        assert to_integer(unsigned(paddle2_y)) > (V_DISPLAY / 2) - (C_PADDLE_HEIGHT / 2)
            report "Error: Paddle 2 did not move down." severity error;

        -- Move Player 2 out of the way (up) so Player 1 scores
        report "TEST 3: Testing out of bounds / Scoring";
        p2_up <= '1';
        wait_frames(50); -- Move P2 to the top of the screen
        p2_up <= '0';

        report "Waiting for ball to cross the screen...";
        wait_frames(100);
        
        assert to_integer(unsigned(score_p1)) > 0
            report "Error: Player 1 did not receive a point when the ball passed Player 2." severity error;

        report "Simulation finished successfully without logic errors!";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
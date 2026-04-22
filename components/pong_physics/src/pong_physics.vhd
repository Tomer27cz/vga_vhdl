library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_physics is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        ce_60hz   : in  std_logic;

        -- Player Inputs
        p1_up     : in  std_logic;
        p1_down   : in  std_logic;
        p2_up     : in  std_logic;
        p2_down   : in  std_logic;

        -- Outputs to the Renderer
        paddle1_y : out std_logic_vector(9 downto 0);
        paddle2_y : out std_logic_vector(9 downto 0);
        ball_x    : out std_logic_vector(9 downto 0);
        ball_y    : out std_logic_vector(9 downto 0);
        score_p1  : out std_logic_vector(7 downto 0);
        score_p2  : out std_logic_vector(7 downto 0)
    );
end entity pong_physics;

architecture behavioral of pong_physics is

    -- Paddles only need Y, their X is fixed
    signal sig_p1_y     : integer range 0 to V_DISPLAY;
    signal sig_p2_y     : integer range 0 to V_DISPLAY;

    -- Ball needs X, Y, and Velocity vectors (dx, dy)
    -- Include negative numbers in case it goes off screen
    signal sig_ball_x   : integer range -100 to 1000 := H_DISPLAY / 2;
    signal sig_ball_y   : integer range -100 to 1000 := V_DISPLAY / 2;
    signal sig_ball_dx  : integer range -20 to 20 := C_BALL_SPEED_X;
    signal sig_ball_dy  : integer range -20 to 20 := C_BALL_SPEED_Y;

    -- Delay after scoring to prevent immediate re-scoring
    signal sig_score_delay : integer range 0 to 360 := INITIAL_RESET_DELAY;

    -- Score tracking
    signal sig_score_p1 : integer range 0 to 255 := 0;
    signal sig_score_p2 : integer range 0 to 255 := 0;

begin

    p_physics : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_p1_y    <= (V_DISPLAY / 2) - (C_PADDLE_HEIGHT / 2);
                sig_p2_y    <= (V_DISPLAY / 2) - (C_PADDLE_HEIGHT / 2);

                sig_ball_x  <= H_DISPLAY / 2;
                sig_ball_y  <= V_DISPLAY / 2;
                sig_ball_dx <= C_BALL_SPEED_X;
                sig_ball_dy <= C_BALL_SPEED_Y;

                sig_score_p1 <= 0;
                sig_score_p2 <= 0;

                sig_score_delay <= INITIAL_RESET_DELAY;

            elsif ce_60hz = '1' then
                --------------------------------------------------------
                -- PADDLE MOVEMENT
                --------------------------------------------------------
                -- Player 1
                if p1_up = '1' and sig_p1_y >= C_PADDLE_SPEED then
                    sig_p1_y <= sig_p1_y - C_PADDLE_SPEED;
                elsif p1_down = '1' and (sig_p1_y + C_PADDLE_HEIGHT + C_PADDLE_SPEED) <= V_DISPLAY then
                    sig_p1_y <= sig_p1_y + C_PADDLE_SPEED;
                end if;

                -- Player 2
                if p2_up = '1' and sig_p2_y >= C_PADDLE_SPEED then
                    sig_p2_y <= sig_p2_y - C_PADDLE_SPEED;
                elsif p2_down = '1' and (sig_p2_y + C_PADDLE_HEIGHT + C_PADDLE_SPEED) <= V_DISPLAY then
                    sig_p2_y <= sig_p2_y + C_PADDLE_SPEED;
                end if;

                --------------------------------------------------------
                -- BALL MOVEMENT
                --------------------------------------------------------
                if sig_score_delay > 0 then
                    sig_score_delay <= sig_score_delay - 1; -- Countdown score delay
                else
                    sig_ball_x <= sig_ball_x + sig_ball_dx;
                    sig_ball_y <= sig_ball_y + sig_ball_dy;
                end  if;

                --------------------------------------------------------
                -- WALL COLLISIONS (Top & Bottom)
                --------------------------------------------------------
                if (sig_ball_y <= 0) and (sig_ball_dy < 0) then
                    sig_ball_dy <= -sig_ball_dy; -- Hit top wall, bounce down
                elsif ((sig_ball_y + C_BALL_SIZE) >= V_DISPLAY) and (sig_ball_dy > 0) then
                    sig_ball_dy <= -sig_ball_dy; -- Hit bottom wall, bounce up
                end if;

                --------------------------------------------------------
                -- PADDLE COLLISIONS (Front-Face & Dynamic Rebound)
                --------------------------------------------------------
                -- Check Player 1 (Left Paddle)
                if (sig_ball_x <= C_P1_X + C_PADDLE_WIDTH) and
                    (sig_ball_x + C_BALL_SIZE >= C_P1_X + C_PADDLE_WIDTH) and
                    (sig_ball_y + C_BALL_SIZE >= sig_p1_y) and
                    (sig_ball_y <= sig_p1_y + C_PADDLE_HEIGHT) and
                    (sig_ball_dx < 0) then

                    sig_ball_dx <= C_BALL_SPEED_X; -- Bounce Right
                end if;

                -- Check Player 2 (Right Paddle)
                if (sig_ball_x + C_BALL_SIZE >= C_P2_X) and
                    (sig_ball_x <= C_P2_X) and
                    (sig_ball_y + C_BALL_SIZE >= sig_p2_y) and
                    (sig_ball_y <= sig_p2_y + C_PADDLE_HEIGHT) and
                    (sig_ball_dx > 0) then

                    sig_ball_dx <= -C_BALL_SPEED_X; -- Bounce Left
                end if;

                --------------------------------------------------------
                -- SCORE / OUT OF BOUNDS
                --------------------------------------------------------
                if sig_ball_x < 0 or sig_ball_x > H_DISPLAY then
                    -- Ball went past a paddle. Reset to center.
                    sig_ball_x <= H_DISPLAY / 2;
                    sig_ball_y <= V_DISPLAY / 2;

                    sig_ball_dx <= -sig_ball_dx; -- Start moving towards the player who just got scored on

                    -- Update score
                    if sig_ball_x < 0 then
                        sig_score_p2 <= sig_score_p2 + 1; -- Player 2 scores
                    else
                        sig_score_p1 <= sig_score_p1 + 1; -- Player 1 scores
                    end if;

                    -- Start score delay to prevent immediate re-scoring
                    sig_score_delay <= SCORE_DELAY_FRAMES;
                end if;
            end if;
        end if;
    end process;

    paddle1_y <= std_logic_vector(to_unsigned(sig_p1_y,    10));
    paddle2_y <= std_logic_vector(to_unsigned(sig_p2_y,    10));

    ball_x <= std_logic_vector(to_signed(sig_ball_x,       10));
    ball_y <= std_logic_vector(to_signed(sig_ball_y,       10));

    score_p1  <= std_logic_vector(to_unsigned(sig_score_p1, 8));
    score_p2  <= std_logic_vector(to_unsigned(sig_score_p2, 8));

end behavioral;
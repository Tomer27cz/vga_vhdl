library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_ai is
    generic (
        G_PADDLE_X     : integer; -- Physical X position of the paddle
        G_ACTIVATION_X : integer  -- The X boundary where this AI acts
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        ce_60hz     : in  std_logic;

        ball_x      : in  std_logic_vector(9 downto 0);
        ball_y      : in  std_logic_vector(9 downto 0);
        paddle_y    : in  std_logic_vector(9 downto 0);

        paddle_up   : out std_logic;
        paddle_down : out std_logic
    );
end entity pong_ai;

architecture behavioral of pong_ai is
    constant C_IS_LEFT_SIDE    : boolean := (G_PADDLE_X < (H_DISPLAY / 2));

    signal sig_ball_center_y   : integer range -100 to 1000;
    signal sig_paddle_center_y : integer range 0 to V_DISPLAY;
    signal sig_ball_x          : integer range 0 to H_TOTAL;
begin

    sig_ball_center_y   <= to_integer(signed(ball_y)) + (C_BALL_SIZE / 2);
    sig_paddle_center_y <= to_integer(unsigned(paddle_y)) + (C_PADDLE_HEIGHT / 2);
    sig_ball_x          <= to_integer(unsigned(ball_x));

    p_ai_logic : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                paddle_up   <= '0';
                paddle_down <= '0';
            elsif ce_60hz = '1' then
                if (C_IS_LEFT_SIDE and sig_ball_x < G_ACTIVATION_X) or
                    (not C_IS_LEFT_SIDE and sig_ball_x >= G_ACTIVATION_X) then

                    if sig_ball_center_y < (sig_paddle_center_y - C_AI_DEADZONE) then
                        paddle_up   <= '1';
                        paddle_down <= '0';
                    elsif sig_ball_center_y > (sig_paddle_center_y + C_AI_DEADZONE) then
                        paddle_up   <= '0';
                        paddle_down <= '1';
                    else
                        paddle_up   <= '0';
                        paddle_down <= '0';
                    end if;

                else
                    paddle_up   <= '0';
                    paddle_down <= '0';
                end if;
            end if;
        end if;
    end process;

end behavioral;
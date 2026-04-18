library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_ai is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        ce_60hz     : in  std_logic;

        ball_y      : in  std_logic_vector(9 downto 0);
        paddle_y    : in  std_logic_vector(9 downto 0);

        paddle_up   : out std_logic;
        paddle_down : out std_logic
    );
end entity pong_ai;

architecture behavioral of pong_ai is
    signal sig_ball_center_y   : integer range -100 to 1000;
    signal sig_paddle_center_y : integer range 0 to V_DISPLAY;
begin

    sig_ball_center_y   <= to_integer(signed(ball_y)) + (C_BALL_SIZE / 2);
    sig_paddle_center_y <= to_integer(unsigned(paddle_y)) + (C_PADDLE_HEIGHT / 2);

    p_ai_logic : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                paddle_up   <= '0';
                paddle_down <= '0';
            elsif ce_60hz = '1' then
                if sig_ball_center_y < (sig_paddle_center_y - C_AI_DEADZONE) then
                    -- Ball is above the paddle deadzone
                    paddle_up   <= '1';
                    paddle_down <= '0';

                elsif sig_ball_center_y > (sig_paddle_center_y + C_AI_DEADZONE) then
                    -- Ball is below the paddle deadzone
                    paddle_up   <= '0';
                    paddle_down <= '1';

                else
                    -- Ball is within deadzone
                    paddle_up   <= '0';
                    paddle_down <= '0';
                end if;
            end if;
        end if;
    end process;

end behavioral;
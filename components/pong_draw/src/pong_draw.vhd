library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity pong_draw is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        ce        : in  std_logic;

        -- VGA Sync Signals
        h_count   : in  std_logic_vector(9 downto 0);
        v_count   : in  std_logic_vector(9 downto 0);
        video_on  : in  std_logic;

        -- Pong Physics Signals (from pong_physics)
        paddle1_y : in  std_logic_vector(9 downto 0);
        paddle2_y : in  std_logic_vector(9 downto 0);
        ball_x    : in  std_logic_vector(9 downto 0);
        ball_y    : in  std_logic_vector(9 downto 0);

        -- RGB Outputs
        red       : out std_logic_vector(3 downto 0);
        green     : out std_logic_vector(3 downto 0);
        blue      : out std_logic_vector(3 downto 0)
    );
end entity pong_draw;

architecture behavioral of pong_draw is
begin
    process(clk)
        variable h_pos : integer;
        variable v_pos : integer;
        variable p1_y  : integer;
        variable p2_y  : integer;
        variable b_x   : integer;
        variable b_y   : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            elsif ce = '1' then
                if video_on = '1' then
                    h_pos := to_integer(unsigned(h_count));
                    v_pos := to_integer(unsigned(v_count));
                    p1_y  := to_integer(unsigned(paddle1_y));
                    p2_y  := to_integer(unsigned(paddle2_y));
                    b_x   := to_integer(signed(ball_x));
                    b_y   := to_integer(signed(ball_y));

                    red   <= "0000";
                    green <= "0000";
                    blue  <= "0000";

                    -- Draw Center Line (Gray)
                    if (h_pos >= (H_DISPLAY / 2) - 1) and (h_pos <= (H_DISPLAY / 2) + 1) then
                        if (v_pos mod 16) < 8 then -- Split into 8 pixel segments for dashed line
                            red   <= "0100";
                            green <= "0100";
                            blue  <= "0100";
                        end if;
                    end if;

                    -- Draw Paddle 1 (Left - White)
                    if (h_pos >= C_P1_X) and (h_pos < C_P1_X + C_PADDLE_WIDTH) and
                        (v_pos >= p1_y) and (v_pos < p1_y + C_PADDLE_HEIGHT) then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    end if;

                    -- Draw Paddle 2 (Right - White)
                    if (h_pos >= C_P2_X) and (h_pos < C_P2_X + C_PADDLE_WIDTH) and
                        (v_pos >= p2_y) and (v_pos < p2_y + C_PADDLE_HEIGHT) then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    end if;

                    -- Draw Ball (Yellow)
                    -- Last so it is on top of the center line
                    if (h_pos >= b_x) and (h_pos < b_x + C_BALL_SIZE) and
                        (v_pos >= b_y) and (v_pos < b_y + C_BALL_SIZE) then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "0000";
                    end if;

                else
                    red   <= (others => '0');
                    green <= (others => '0');
                    blue  <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end behavioral;
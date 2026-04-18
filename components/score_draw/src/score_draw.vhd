library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.const_pkg.all;

entity score_draw is
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
end entity score_draw;

architecture behavioral of score_draw is

    -- BCD Signals from bin2bcd
    signal p1_bcd_h, p1_bcd_t, p1_bcd_o : std_logic_vector(3 downto 0);
    signal p2_bcd_h, p2_bcd_t, p2_bcd_o : std_logic_vector(3 downto 0);

    -- Dynamic X and Y position signals for each digit
    signal p1_x_h, p1_x_t, p1_x_o : std_logic_vector(9 downto 0);
    signal p2_x_h, p2_x_t, p2_x_o : std_logic_vector(9 downto 0);
    signal y_pos_all              : std_logic_vector(9 downto 0);

    -- RGB output wires for Player 1 digits
    signal p1_r_h, p1_g_h, p1_b_h : std_logic_vector(3 downto 0);
    signal p1_r_t, p1_g_t, p1_b_t : std_logic_vector(3 downto 0);
    signal p1_r_o, p1_g_o, p1_b_o : std_logic_vector(3 downto 0);

    -- RGB output wires for Player 2 digits
    signal p2_r_h, p2_g_h, p2_b_h : std_logic_vector(3 downto 0);
    signal p2_r_t, p2_g_t, p2_b_t : std_logic_vector(3 downto 0);
    signal p2_r_o, p2_g_o, p2_b_o : std_logic_vector(3 downto 0);

    component digit_draw is
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
    end component digit_draw;

    component bin2bcd is
        port (
            bin      : in  std_logic_vector(7 downto 0);
            hundreds : out std_logic_vector(3 downto 0);
            tens     : out std_logic_vector(3 downto 0);
            ones     : out std_logic_vector(3 downto 0)
        );
    end component bin2bcd;

begin

    -- Fixed Y position for all digits
    y_pos_all <= std_logic_vector(to_unsigned(C_SCORE_Y, 10));

    -------------------------------------------------------------------------
    -- Dynamic Positioning and Leading Zero Suppression
    -------------------------------------------------------------------------
    process(p1_bcd_h, p1_bcd_t, p2_bcd_h, p2_bcd_t)
    begin
        -- Player 1 Layout (Left Side)
        -- The Ones digit is always fixed near the center.
        p1_x_o <= std_logic_vector(to_unsigned(C_SCORE_P1_POS1, 10));

        if p1_bcd_h /= "0000" then
            -- 3 digits active
            p1_x_t <= std_logic_vector(to_unsigned(C_SCORE_P1_POS2, 10));
            p1_x_h <= std_logic_vector(to_unsigned(C_SCORE_P1_POS3, 10));
        elsif p1_bcd_t /= "0000" then
            -- 2 digits active
            p1_x_t <= std_logic_vector(to_unsigned(C_SCORE_P1_POS2, 10));
            p1_x_h <= (others => '1'); -- Off-screen
        else
            -- 1 digit active
            p1_x_t <= (others => '1'); -- Off-screen
            p1_x_h <= (others => '1'); -- Off-screen
        end if;

        -- Player 2 Layout (Right Side)
        -- The MOST significant active digit is placed at the center line.
        if p2_bcd_h /= "0000" then
            -- 3 digits active
            p2_x_h <= std_logic_vector(to_unsigned(C_SCORE_P2_POS1, 10));
            p2_x_t <= std_logic_vector(to_unsigned(C_SCORE_P2_POS2, 10));
            p2_x_o <= std_logic_vector(to_unsigned(C_SCORE_P2_POS3, 10));
        elsif p2_bcd_t /= "0000" then
            -- 2 digits active
            p2_x_h <= (others => '1'); -- Off-screen
            p2_x_t <= std_logic_vector(to_unsigned(C_SCORE_P2_POS1, 10));
            p2_x_o <= std_logic_vector(to_unsigned(C_SCORE_P2_POS2, 10));
        else
            -- 1 digit active
            p2_x_h <= (others => '1'); -- Off-screen
            p2_x_t <= (others => '1'); -- Off-screen
            p2_x_o <= std_logic_vector(to_unsigned(C_SCORE_P2_POS1, 10));
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Binary to BCD Converters
    -------------------------------------------------------------------------
    u_bin2bcd_p1 : bin2bcd
        port map (
            bin      => p1_score,
            hundreds => p1_bcd_h,
            tens     => p1_bcd_t,
            ones     => p1_bcd_o
        );

    u_bin2bcd_p2 : bin2bcd
        port map (
            bin      => p2_score,
            hundreds => p2_bcd_h,
            tens     => p2_bcd_t,
            ones     => p2_bcd_o
        );

    -------------------------------------------------------------------------
    -- Player 1 Digit Draw Components
    -------------------------------------------------------------------------
    u_digit_p1_h : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p1_bcd_h,
            x_pos    => p1_x_h,
            y_pos    => y_pos_all,
            red      => p1_r_h,
            green    => p1_g_h,
            blue     => p1_b_h
        );

    u_digit_p1_t : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p1_bcd_t,
            x_pos    => p1_x_t,
            y_pos    => y_pos_all,
            red      => p1_r_t,
            green    => p1_g_t,
            blue     => p1_b_t
        );

    u_digit_p1_o : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p1_bcd_o,
            x_pos    => p1_x_o,
            y_pos    => y_pos_all,
            red      => p1_r_o,
            green    => p1_g_o,
            blue     => p1_b_o
        );

    -------------------------------------------------------------------------
    -- Player 2 Digit Draw Components
    -------------------------------------------------------------------------
    u_digit_p2_h : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p2_bcd_h,
            x_pos    => p2_x_h,
            y_pos    => y_pos_all,
            red      => p2_r_h,
            green    => p2_g_h,
            blue     => p2_b_h
        );

    u_digit_p2_t : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p2_bcd_t,
            x_pos    => p2_x_t,
            y_pos    => y_pos_all,
            red      => p2_r_t,
            green    => p2_g_t,
            blue     => p2_b_t
        );

    u_digit_p2_o : digit_draw
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            bcd_val  => p2_bcd_o,
            x_pos    => p2_x_o,
            y_pos    => y_pos_all,
            red      => p2_r_o,
            green    => p2_g_o,
            blue     => p2_b_o
        );

    -------------------------------------------------------------------------
    -- Output RGB Combiner
    -------------------------------------------------------------------------
    red   <= p1_r_h or p1_r_t or p1_r_o or p2_r_h or p2_r_t or p2_r_o;
    green <= p1_g_h or p1_g_t or p1_g_o or p2_g_h or p2_g_t or p2_g_o;
    blue  <= p1_b_h or p1_b_t or p1_b_o or p2_b_h or p2_b_t or p2_b_o;

end behavioral;
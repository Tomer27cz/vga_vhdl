library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity vga_top is
    port (
        CLK100MHZ : in  std_logic;

        -- Physical Buttons
        BTNC      : in  std_logic; -- Global Reset
        BTNU      : in  std_logic; -- P1 Up
        BTNR      : in  std_logic; -- P1 Down
        BTNL      : in  std_logic; -- P2 Up
        BTND      : in  std_logic; -- P2 Down

        -- Switches for Mode Selection
        -- SW(0): Pong / Test Pattern
        -- SW(1): AI for Player 2
        -- SW(2): AI for Player 1
        SW        : in  std_logic_vector(2 downto 0);

        -- VGA Outputs
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic;
        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0)
    );
end entity vga_top;

architecture Behavioral of vga_top is

    ---------------------------------------------------------------------------
    -- Shared Signals
    ---------------------------------------------------------------------------
    signal ce_25M     : std_logic;

    signal h_count    : std_logic_vector(9 downto 0);
    signal v_count    : std_logic_vector(9 downto 0);
    signal video_on   : std_logic;

    ---------------------------------------------------------------------------
    -- Debounced Buttons
    ---------------------------------------------------------------------------
    signal rst_sync         : std_logic;
    signal btn_p1_up_sync   : std_logic;
    signal btn_p1_down_sync : std_logic;
    signal btn_p2_up_sync   : std_logic;
    signal btn_p2_down_sync : std_logic;

    ---------------------------------------------------------------------------
    -- Intermediate Color Signals
    ---------------------------------------------------------------------------
    signal test_r, test_g, test_b                : std_logic_vector(3 downto 0);
    signal pong_draw_r, pong_draw_g, pong_draw_b : std_logic_vector(3 downto 0);
    signal score_r, score_g, score_b             : std_logic_vector(3 downto 0);
    signal pong_r, pong_g, pong_b                : std_logic_vector(3 downto 0);

    ---------------------------------------------------------------------------
    -- Pong Physics & AI Interconnects
    ---------------------------------------------------------------------------
    signal p1_up, p1_down               : std_logic;
    signal p2_up, p2_down               : std_logic;

    signal ai_p1_up, ai_p1_down         : std_logic;
    signal ai_p2_up, ai_p2_down         : std_logic;

    signal paddle1_y, paddle2_y         : std_logic_vector(9 downto 0);
    signal ball_x, ball_y               : std_logic_vector(9 downto 0);
    signal score_p1, score_p2           : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------------
    -- Mode Control & Reset Logic
    ---------------------------------------------------------------------------
    signal pong_active  : std_logic;
    signal ce_pong_60Hz : std_logic;
    signal pong_rst     : std_logic;

    ---------------------------------------------------------------------------
    -- Component Declarations
    ---------------------------------------------------------------------------
    component clk_en is
        generic ( G_MAX : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component;

    component debounce is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            btn_in      : in  std_logic;
            btn_state   : out std_logic;
            btn_press   : out std_logic
        );
    end component;

    component vga_sync is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            ce        : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            hcount    : out std_logic_vector(9 downto 0);
            vcount    : out std_logic_vector(9 downto 0);
            video_on  : out std_logic
        );
    end component;

    component img_gen is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            ce       : in  std_logic;
            h_count  : in  std_logic_vector(9 downto 0);
            v_count  : in  std_logic_vector(9 downto 0);
            video_on : in  std_logic;
            red      : out std_logic_vector(3 downto 0);
            green    : out std_logic_vector(3 downto 0);
            blue     : out std_logic_vector(3 downto 0)
        );
    end component;

    component pong_physics is
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

    component pong_ai is
        generic (
            G_PADDLE_X     : integer;
            G_ACTIVATION_X : integer
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
    end component pong_ai;

    component pong_draw is
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

    component score_draw is
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

    ---------------------------------------------------------------------------
    -- Clock Enable
    ---------------------------------------------------------------------------
    -- 25 MHz for VGA pixel clock (100 MHz / 4)
    clk_en_25M : clk_en
        generic map ( G_MAX => 4 )
        port map (
            clk => CLK100MHZ,
            rst => rst_sync,
            ce  => ce_25M
        );

    ---------------------------------------------------------------------------
    -- Debouncers
    ---------------------------------------------------------------------------
    deb_rst : debounce
        port map (clk => CLK100MHZ, rst => '0', btn_in => BTNC, btn_state => rst_sync, btn_press => open);

    deb_p1_up : debounce
        port map (clk => CLK100MHZ, rst => rst_sync, btn_in => BTNU, btn_state => btn_p1_up_sync, btn_press => open);

    deb_p1_down : debounce
        port map (clk => CLK100MHZ, rst => rst_sync, btn_in => BTNR, btn_state => btn_p1_down_sync, btn_press => open);

    deb_p2_up : debounce
        port map (clk => CLK100MHZ, rst => rst_sync, btn_in => BTNL, btn_state => btn_p2_up_sync, btn_press => open);

    deb_p2_down : debounce
        port map (clk => CLK100MHZ, rst => rst_sync, btn_in => BTND, btn_state => btn_p2_down_sync, btn_press => open);

    ---------------------------------------------------------------------------
    -- Stop & Reset Logic
    ---------------------------------------------------------------------------
    pong_active <= '1' when SW(0) = '1' else '0';
    ce_pong_60Hz <= '1' when (v_count = "0111100000" and h_count = "0000000000" and ce_25M = '1' and pong_active = '1') else '0';

    pong_rst <= rst_sync or not(pong_active);

    ---------------------------------------------------------------------------
    -- Input Multiplexing
    ---------------------------------------------------------------------------
    p1_up   <= ai_p1_up   when SW(2) = '1' else btn_p1_up_sync;
    p1_down <= ai_p1_down when SW(2) = '1' else btn_p1_down_sync;

    p2_up   <= ai_p2_up   when SW(1) = '1' else btn_p2_up_sync;
    p2_down <= ai_p2_down when SW(1) = '1' else btn_p2_down_sync;

    ---------------------------------------------------------------------------
    -- Master VGA Synchronization
    ---------------------------------------------------------------------------
    vga_sync_inst : vga_sync
        port map (
            clk      => CLK100MHZ,
            rst      => rst_sync,
            ce       => ce_25M,
            hsync    => VGA_HS,
            vsync    => VGA_VS,
            hcount   => h_count,
            vcount   => v_count,
            video_on => video_on
        );

    ---------------------------------------------------------------------------
    -- Video Generators
    ---------------------------------------------------------------------------
    img_gen_inst : img_gen
        port map (
            clk      => CLK100MHZ,
            rst      => rst_sync,
            ce       => ce_25M,
            h_count  => h_count,
            v_count  => v_count,
            video_on => video_on,
            red      => test_r,
            green    => test_g,
            blue     => test_b
        );

    pong_physics_inst : pong_physics
        port map (
            clk       => CLK100MHZ,
            rst       => pong_rst,
            ce_60hz   => ce_pong_60Hz,
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

    pong_ai_p1_inst : pong_ai
        generic map (
            G_PADDLE_X => C_P1_X,
            G_ACTIVATION_X => (H_DISPLAY / 2)
        )
        port map (
            clk         => CLK100MHZ,
            rst         => pong_rst,
            ce_60hz     => ce_pong_60Hz,
            ball_x      => ball_x,
            ball_y      => ball_y,
            paddle_y    => paddle1_y,
            paddle_up   => ai_p1_up,
            paddle_down => ai_p1_down
        );

    pong_ai_p2_inst : pong_ai
        generic map (
            G_PADDLE_X => C_P2_X,
            G_ACTIVATION_X => (H_DISPLAY / 2)
        )
        port map (
            clk         => CLK100MHZ,
            rst         => pong_rst,
            ce_60hz     => ce_pong_60Hz,
            ball_x      => ball_x,
            ball_y      => ball_y,
            paddle_y    => paddle2_y,
            paddle_up   => ai_p2_up,
            paddle_down => ai_p2_down
        );

    pong_draw_inst : pong_draw
        port map (
            clk       => CLK100MHZ,
            rst       => pong_rst,
            ce        => ce_25M,
            h_count   => h_count,
            v_count   => v_count,
            video_on  => video_on,
            paddle1_y => paddle1_y,
            paddle2_y => paddle2_y,
            ball_x    => ball_x,
            ball_y    => ball_y,
            red       => pong_draw_r,
            green     => pong_draw_g,
            blue      => pong_draw_b
        );

    score_draw_inst : score_draw
        port map (
            clk       => CLK100MHZ,
            rst       => pong_rst,
            ce        => ce_25M,
            h_count   => h_count,
            v_count   => v_count,
            video_on  => video_on,
            p1_score  => score_p1,
            p2_score  => score_p2,
            red       => score_r,
            green     => score_g,
            blue      => score_b
        );

    pong_r <= pong_draw_r or score_r;
    pong_g <= pong_draw_g or score_g;
    pong_b <= pong_draw_b or score_b;

    ---------------------------------------------------------------------------
    -- Output Multiplexing
    ---------------------------------------------------------------------------
    process(SW, test_r, test_g, test_b, pong_r, pong_g, pong_b)
    begin
        if SW(0) = '1' then
            VGA_R <= pong_r;
            VGA_G <= pong_g;
            VGA_B <= pong_b;
        else
            VGA_R <= test_r;
            VGA_G <= test_g;
            VGA_B <= test_b;
        end if;
    end process;

end architecture Behavioral;
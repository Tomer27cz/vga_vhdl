library ieee;
    use ieee.std_logic_1164.all;

entity pong_only_top is
    port (
        CLK100MHZ : in  std_logic;

        BTNC      : in  std_logic; -- RESET
        BTNU      : in  std_logic; -- P1_UP
        BTNR      : in  std_logic; -- P1_DOWN
        BTNL      : in  std_logic; -- P2_UP
        BTND      : in  std_logic; -- P2_DOWN

        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0);
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic
    );
end entity pong_only_top;

architecture behavioral of pong_only_top is

    component debounce is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            btn_in      : in  std_logic;
            btn_state   : out std_logic;
            btn_press   : out std_logic
        );
    end component debounce;

    component clk_en is
        generic ( G_MAX : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component clk_en;

    component vga_sync is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            ce       : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            hcount   : out std_logic_vector (9 downto 0);
            vcount   : out std_logic_vector (9 downto 0);
            video_on : out std_logic
        );
    end component vga_sync;

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
    end component pong_physics;

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
    end component pong_draw;

    -- Debounced buttons
    signal rst_sync     : std_logic;
    signal p1_up_sync   : std_logic;
    signal p1_down_sync : std_logic;
    signal p2_up_sync   : std_logic;
    signal p2_down_sync : std_logic;

    -- Clock enable
    signal ce_25M       : std_logic;
    signal ce_60Hz      : std_logic;

    -- VGA Sync
    signal h_count      : std_logic_vector(9 downto 0);
    signal v_count      : std_logic_vector(9 downto 0);
    signal video_on     : std_logic;

    -- Physics to Draw
    signal paddle1_y    : std_logic_vector(9 downto 0);
    signal paddle2_y    : std_logic_vector(9 downto 0);
    signal ball_x       : std_logic_vector(9 downto 0);
    signal ball_y       : std_logic_vector(9 downto 0);

begin

    deb_reset : debounce port map (
        clk => CLK100MHZ, rst => '0', btn_in => BTNC, btn_state => rst_sync, btn_press => open
    );
    deb_p1_up : debounce port map (
        clk => CLK100MHZ, rst => '0', btn_in => BTNU, btn_state => p1_up_sync, btn_press => open
    );
    deb_p1_down : debounce port map (
        clk => CLK100MHZ, rst => '0', btn_in => BTNR, btn_state => p1_down_sync, btn_press => open
    );
    deb_p2_up : debounce port map (
        clk => CLK100MHZ, rst => '0', btn_in => BTNL, btn_state => p2_up_sync, btn_press => open
    );
    deb_p2_down : debounce port map (
        clk => CLK100MHZ, rst => '0', btn_in => BTND, btn_state => p2_down_sync, btn_press => open
    );

    -- (100 MHz / 4 = 25 MHz pixel clock)
    clk_en_25M : clk_en
    generic map ( G_MAX => 4 )
    port map (
        clk => CLK100MHZ,
        rst => rst_sync,
        ce  => ce_25M
    );

    -- (60 Hz update rate for physics)
    ce_60Hz <= '1' when v_count = "0111100000" and h_count = "0000000000" and ce_25M = '1' else '0';

    vga_sync_0 : vga_sync
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

    pong_physics_0 : pong_physics
    port map (
        clk       => CLK100MHZ,
        rst       => rst_sync,
        ce_60hz   => ce_60Hz,
        p1_up     => p1_up_sync,
        p1_down   => p1_down_sync,
        p2_up     => p2_up_sync,
        p2_down   => p2_down_sync,
        paddle1_y => paddle1_y,
        paddle2_y => paddle2_y,
        ball_x    => ball_x,
        ball_y    => ball_y,
        score_p1  => open,
        score_p2  => open
    );

    pong_draw_0 : pong_draw
    port map (
        clk       => CLK100MHZ,
        rst       => rst_sync,
        ce        => ce_25M,
        h_count   => h_count,
        v_count   => v_count,
        video_on  => video_on,
        paddle1_y => paddle1_y,
        paddle2_y => paddle2_y,
        ball_x    => ball_x,
        ball_y    => ball_y,
        red       => VGA_R,
        green     => VGA_G,
        blue      => VGA_B
    );

end behavioral;
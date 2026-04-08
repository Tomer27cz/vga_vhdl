library ieee;
    use ieee.std_logic_1164.all;

entity pattern_only_top is
    port (
        CLK100MHZ  : in  std_logic;
        BTND       : in  std_logic;
        VGA_R      : out std_logic_vector(3 downto 0);
        VGA_G      : out std_logic_vector(3 downto 0);
        VGA_B      : out std_logic_vector(3 downto 0);
        VGA_HS     : out std_logic;
        VGA_VS     : out std_logic
    );
end entity pattern_only_top;

architecture behavioral of pattern_only_top is

    -- Clocking Wizard (Generate 25.175 MHz from 100 MHz)
    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            reset    : in  std_logic;
            locked   : out std_logic;
            clk_in1  : in  std_logic
        );
    end component;

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
    end component img_gen;

    component debounce is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            btn_in      : in  std_logic;
            btn_state   : out std_logic;
            btn_press   : out std_logic
        );
    end component debounce;

    signal clk_25_175     : std_logic;
    signal locked         : std_logic;
    signal sys_rst        : std_logic;
    signal h_count        : std_logic_vector(9 downto 0);
    signal v_count        : std_logic_vector(9 downto 0);
    signal video_on       : std_logic;
    signal btnd_debounced : std_logic;
begin

    -- Debouncer for the BTND input
    debounce_0 : debounce
    port map (
        clk         => CLK100MHZ,
        rst         => '0',
        btn_in      => BTND,
        btn_state   => btnd_debounced,
        btn_press   => open
    );

    -- Clocking Wizard IP
    clk_wiz_inst : clk_wiz_0
    port map (
        clk_out1 => clk_25_175,
        reset    => '0',
        locked   => locked,
        clk_in1  => CLK100MHZ
    );

    sys_rst <= btnd_debounced or (not locked);

    -- Generate VGA synchronisation
    vga_sync_0 : vga_sync
    port map (
        clk      => clk_25_175,
        rst      => sys_rst,
        ce       => '1',
        hsync    => VGA_HS,
        vsync    => VGA_VS,
        hcount   => h_count,
        vcount   => v_count,
        video_on => video_on
    );

    -- Generate Test Image (SMPTE Color Bars)
    img_gen_0 : img_gen
    port map (
        clk      => clk_25_175,
        rst      => sys_rst,
        ce       => '1',
        h_count  => h_count,
        v_count  => v_count,
        video_on => video_on,
        red      => VGA_R,
        green    => VGA_G,
        blue     => VGA_B
    );

end behavioral;
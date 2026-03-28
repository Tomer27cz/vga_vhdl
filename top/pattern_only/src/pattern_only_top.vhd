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

    component clk_en is
        generic (G_MAX : positive := 4); -- 25 MHz pixel clock
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

    signal ce       : std_logic;
    signal hsync    : std_logic;
    signal vsync    : std_logic;
    signal h_count  : std_logic_vector(9 downto 0);
    signal v_count  : std_logic_vector(9 downto 0);
    signal video_on : std_logic;
begin

    -- Delay sync signals by 1 pixel cycle (using ce) to match the color output delay
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if ce = '1' then
                VGA_HS <= hsync;
                VGA_VS <= vsync;
            end if;
        end if;
    end process;

    -- Generate 25 MHz pixel clock enable pulse
    clk_en_0 : clk_en
    generic map (G_MAX => 4)  -- 100 MHz / 4 = 25 MHz
    port map (
        clk   => CLK100MHZ,
        rst   => BTND,
        ce    => ce
    );

    -- Generate VGA synchronisation
    vga_sync_0 : vga_sync
    port map (
        clk      => CLK100MHZ,
        rst      => BTND,
        ce       => ce,
        hsync    => hsync,
        vsync    => vsync,
        hcount   => h_count,
        vcount   => v_count,
        video_on => video_on
    );

    -- Generate Test Image (SMPTE Color Bars)
    img_gen_0 : img_gen
    port map (
        clk      => CLK100MHZ,
        rst      => BTND,
        ce       => ce,
        h_count  => h_count,
        v_count  => v_count,
        video_on => video_on,
        red      => VGA_R,
        green    => VGA_G,
        blue     => VGA_B
    );

end behavioral;
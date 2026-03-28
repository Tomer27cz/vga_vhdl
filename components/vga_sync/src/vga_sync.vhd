library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity vga_sync is
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
end entity vga_sync;

architecture behavioral of vga_sync is
    -- 640x480 @ 60Hz timings (Pixel Clock = 25 MHz)
    constant H_DISPLAY : integer := 640;                              -- Active video pixels per line
    constant H_FP      : integer := 16;                               -- Front porch (pixels)
    constant H_SYNC    : integer := 96;                               -- Sync pulse width (pixels)
    constant H_BP      : integer := 48;                               -- Back porch (pixels)
    constant H_TOTAL   : integer := H_DISPLAY + H_FP + H_SYNC + H_BP; -- 800

    constant V_DISPLAY : integer := 480;                              -- Active video lines per frame
    constant V_FP      : integer := 10;                               -- Front porch (lines)
    constant V_SYNC    : integer := 2;                                -- Sync pulse width (lines)
    constant V_BP      : integer := 33;                               -- Back porch (lines)
    constant V_TOTAL   : integer := V_DISPLAY + V_FP + V_SYNC + V_BP; -- 525

    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                h_cnt <= (others => '0');
                v_cnt <= (others => '0');
            elsif ce = '1' then
                -- Horizontal Counter
                if h_cnt = (H_TOTAL - 1) then
                    h_cnt <= (others => '0');

                    -- Vertical Counter (increments only on horizontal wrap)
                    if v_cnt = (V_TOTAL - 1) then
                        v_cnt <= (others => '0');
                    else
                        v_cnt <= v_cnt + 1;
                    end if;
                else
                    h_cnt <= h_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Generate sync pulses (Active Low for 640x480)
    hsync <= '0' when (h_cnt >= H_DISPLAY + H_FP) and (h_cnt < H_DISPLAY + H_FP + H_SYNC) else '1';
    vsync <= '0' when (v_cnt >= V_DISPLAY + V_FP) and (v_cnt < V_DISPLAY + V_FP + V_SYNC) else '1';

    -- Enable video only within the visible area
    video_on <= '1' when (h_cnt < H_DISPLAY) and (v_cnt < V_DISPLAY) else '0';

    -- Output coordinates
    hcount <= std_logic_vector(h_cnt);
    vcount <= std_logic_vector(v_cnt);

end behavioral;

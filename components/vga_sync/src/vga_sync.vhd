library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

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

    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                h_cnt <= (others => '0');
                v_cnt <= (others => '0');
                hsync <= '1'; -- Default inactive state
                vsync <= '1'; -- Default inactive state
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

                -- Generate sync pulses (Active Low for 640x480)
                -- Here match the 1-clock delay of RGB output
                if (h_cnt >= H_DISPLAY + H_FP) and (h_cnt < H_DISPLAY + H_FP + H_SYNC) then
                    hsync <= '0';
                else
                    hsync <= '1';
                end if;

                if (v_cnt >= V_DISPLAY + V_FP) and (v_cnt < V_DISPLAY + V_FP + V_SYNC) then
                    vsync <= '0';
                else
                    vsync <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Enable video only within the visible area
    video_on <= '1' when (h_cnt < H_DISPLAY) and (v_cnt < V_DISPLAY) else '0';

    -- Output coordinates
    hcount <= std_logic_vector(h_cnt);
    vcount <= std_logic_vector(v_cnt);

end behavioral;

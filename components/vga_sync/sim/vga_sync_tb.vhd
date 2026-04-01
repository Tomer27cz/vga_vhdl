library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync_tb is
end entity;

architecture tb of vga_sync_tb is
    -- 100 MHz system clock
    constant CLK_PERIOD : time := 10 ns;

    signal clk        : std_logic := '1';
    signal rst        : std_logic;
    signal ce         : std_logic;

    signal hsync      : std_logic;
    signal vsync      : std_logic;
    signal hcount     : std_logic_vector (9 downto 0);
    signal vcount     : std_logic_vector (9 downto 0);
    signal visible    : std_logic;

    signal TbSimEnded : std_logic := '0';

    component clk_en
        generic (G_MAX : positive := 4);
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component;

    component vga_sync
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            ce      : in  std_logic;
            hsync   : out std_logic;
            vsync   : out std_logic;
            hcount  : out std_logic_vector (9 downto 0);
            vcount  : out std_logic_vector (9 downto 0);
            video_on : out std_logic
        );
    end component;

begin

    dut_clk_en : clk_en
        generic map (G_MAX => 4) -- 25 MHz for VGA
        port map (
            clk => clk,
            rst => rst,
            ce  => ce
        );

    dut_vga : vga_sync
        port map (
            clk     => clk,
            rst     => rst,
            ce      => ce,
            hsync   => hsync,
            vsync   => vsync,
            hcount  => hcount,
            vcount  => vcount,
            video_on => visible
        );

    clk <= not clk after CLK_PERIOD/2 when TbSimEnded /= '1' else '0';

    p_stim : process
    begin

        report "Asserting reset";
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        report "Simulating VGA signals for one full frame...";
        wait for 17 ms; -- A 640x480 frame @ 60Hz takes ~16.68 ms to complete.

        report "Simulation finished";
        TbSimEnded <= '1';
        wait;

    end process;
end architecture;
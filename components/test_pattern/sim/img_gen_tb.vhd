library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity img_gen_tb is
end entity;

architecture tb of img_gen_tb is
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

    signal clk         : std_logic := '1';
    signal rst         : std_logic;
    signal ce          : std_logic;

    signal hsync       : std_logic;
    signal vsync       : std_logic;
    signal hcount      : std_logic_vector (9 downto 0);
    signal vcount      : std_logic_vector (9 downto 0);
    signal video_on    : std_logic;

    signal red         : std_logic_vector(7 downto 0);
    signal green       : std_logic_vector(7 downto 0);
    signal blue        : std_logic_vector(7 downto 0);

    signal TbSimEnded  : std_logic := '0';

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
            clk      : in  std_logic;
            rst      : in  std_logic;
            ce       : in  std_logic;
            hsync    : out std_logic;
            vsync    : out std_logic;
            hcount   : out std_logic_vector (9 downto 0);
            vcount   : out std_logic_vector (9 downto 0);
            video_on : out std_logic
        );
    end component;

    component img_gen
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            h_count  : in  std_logic_vector(9 downto 0);
            v_count  : in  std_logic_vector(9 downto 0);
            video_on : in  std_logic;
            red      : out std_logic_vector(7 downto 0);
            green    : out std_logic_vector(7 downto 0);
            blue     : out std_logic_vector(7 downto 0)
        );
    end component;

begin

    dut_clk_en : clk_en
        generic map (G_MAX => 4) -- Clock enable (25 MHz for 640x480 VGA)
        port map (
            clk => clk,
            rst => rst,
            ce  => ce
        );

    dut_vga : vga_sync
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            hsync    => hsync,
            vsync    => vsync,
            hcount   => hcount,
            vcount   => vcount,
            video_on => video_on
        );

    dut_img : img_gen
        port map (
            clk      => clk,
            rst      => rst,
            h_count  => hcount,
            v_count  => vcount,
            video_on => video_on,
            red      => red,
            green    => green,
            blue     => blue
        );

    clk <= not clk after CLK_PERIOD/2 when TbSimEnded /= '1' else '0';

    p_stim : process
    begin
        report "Starting simulation: Asserting reset";
        rst <= '1';
        wait for 100 ns;

        rst <= '0';
        report "Reset released";

        -- Process a few horizontal lines
        -- Line at 25MHz takes 32 us (800 pixels * 40 ns per pixel)
        -- 100 us ==> 3 horizontal sweeps
        wait for 100 us;

        report "Simulation finished.";
        TbSimEnded <= '1';
        wait;
    end process;

end architecture;
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity img_gen is
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
end entity img_gen;

architecture behavioral of img_gen is
begin
    process(clk)
        variable h_pos : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            else
                -- ONLY output colors when video_on is High to protect the blanking intervals
                if video_on = '1' then
                    h_pos := to_integer(unsigned(h_count));

                    -- EBU Color Bars: White, Yellow, Cyan, Green, Magenta, Red, Blue, Black

                    if h_pos < 80 then              -- White
                        red   <= "11111111"; -- 255
                        green <= "11111111"; -- 255
                        blue  <= "11111111"; -- 255
                    elsif h_pos < 160 then          -- Yellow
                        red   <= "11111111"; -- 255
                        green <= "11111111"; -- 255
                        blue  <= "00000000"; -- 0
                    elsif h_pos < 240 then          -- Cyan
                        red   <= "00000000"; -- 0
                        green <= "11111111"; -- 255
                        blue  <= "11111111"; -- 255
                    elsif h_pos < 320 then          -- Green
                        red   <= "00000000"; -- 0
                        green <= "11111111"; -- 255
                        blue  <= "00000000"; -- 0
                    elsif h_pos < 400 then          -- Magenta
                        red   <= "11111111"; -- 255
                        green <= "00000000"; -- 0
                        blue  <= "11111111"; -- 255
                    elsif h_pos < 480 then          -- Red
                        red   <= "11111111"; -- 255
                        green <= "00000000"; -- 0
                        blue  <= "00000000"; -- 0
                    elsif h_pos < 560 then          -- Blue
                        red   <= "00000000"; -- 0
                        green <= "00000000"; -- 0
                        blue  <= "11111111"; -- 255
                    else                            -- Black
                        red   <= "00000000"; -- 0
                        green <= "00000000"; -- 0
                        blue  <= "00000000"; -- 0
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
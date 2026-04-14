library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;

entity img_gen is
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
end entity img_gen;

architecture behavioral of img_gen is
begin
    process(clk)
        variable h_pos : integer;
        variable v_pos : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            elsif ce = '1' then
                -- ONLY output colors when video_on is High to protect the blanking intervals
                if video_on = '1' then
                    h_pos := to_integer(unsigned(h_count));
                    v_pos := to_integer(unsigned(v_count));

                    -- ==========================================
                    -- SMPTE Color Bars
                    -- ==========================================

                    -- Top Section (67% of screen)
                    -- 7 Bars: White, Yellow, Cyan, Green, Magenta, Red, Blue
                    if v_pos < (V_DISPLAY * 67 / 100) then
                        if h_pos < (H_DISPLAY / 7) then            -- White
                            red   <= "1111"; green <= "1111"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 2 / 7) then     -- Yellow
                            red   <= "1111"; green <= "1111"; blue  <= "0000";
                        elsif h_pos < (H_DISPLAY * 3 / 7) then     -- Cyan
                            red   <= "0000"; green <= "1111"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 4 / 7) then     -- Green
                            red   <= "0000"; green <= "1111"; blue  <= "0000";
                        elsif h_pos < (H_DISPLAY * 5 / 7) then     -- Magenta
                            red   <= "1111"; green <= "0000"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 6 / 7) then     -- Red
                            red   <= "1111"; green <= "0000"; blue  <= "0000";
                        else                          -- Blue
                            red   <= "0000"; green <= "0000"; blue  <= "1111";
                        end if;

                        -- Middle Section (8% of screen)
                        -- Castellated: Blue, Black, Magenta, Black, Cyan, Black, White
                    elsif v_pos < (V_DISPLAY * 75 / 100) then
                        if h_pos < (H_DISPLAY / 7) then            -- Blue
                            red   <= "0000"; green <= "0000"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 2 / 7) then     -- Black
                            red   <= "0000"; green <= "0000"; blue  <= "0000";
                        elsif h_pos < (H_DISPLAY * 3 / 7) then     -- Magenta
                            red   <= "1111"; green <= "0000"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 4 / 7) then     -- Black
                            red   <= "0000"; green <= "0000"; blue  <= "0000";
                        elsif h_pos < (H_DISPLAY * 5 / 7) then     -- Cyan
                            red   <= "0000"; green <= "1111"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY * 6 / 7) then     -- Black
                            red   <= "0000"; green <= "0000"; blue  <= "0000";
                        else                          -- White
                            red   <= "1111"; green <= "1111"; blue  <= "1111";
                        end if;

                        -- Bottom Section (25% of screen)
                        -- -I, White, Q, Black (Simplified Pluge for 4-bit depth)
                    else
                        if h_pos < (H_DISPLAY / 6) then            -- -I (Dark Blue/Indigo)
                            red   <= "0000"; green <= "0000"; blue  <= "1000";
                        elsif h_pos < (H_DISPLAY * 2 / 6) then     -- White
                            red   <= "1111"; green <= "1111"; blue  <= "1111";
                        elsif h_pos < (H_DISPLAY / 2) then         -- Q (Dark Purple)
                            red   <= "0100"; green <= "0000"; blue  <= "1000";
                        else                                       -- Black (covers the Pluge area)
                            red   <= "0000"; green <= "0000"; blue  <= "0000";
                        end if;
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
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.const_pkg.all;
    use work.font_pkg.all;

entity digit_draw is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        ce        : in  std_logic;

        h_count   : in  std_logic_vector(9 downto 0);
        v_count   : in  std_logic_vector(9 downto 0);
        video_on  : in  std_logic;

        bcd_val   : in  std_logic_vector(3 downto 0);
        x_pos     : in  std_logic_vector(9 downto 0);
        y_pos     : in  std_logic_vector(9 downto 0);

        red       : out std_logic_vector(3 downto 0);
        green     : out std_logic_vector(3 downto 0);
        blue      : out std_logic_vector(3 downto 0)
    );
end entity digit_draw;

architecture behavioral of digit_draw is
begin
    process(clk)
        variable h_pos   : integer;
        variable v_pos   : integer;
        variable x_p     : integer;
        variable y_p     : integer;
        variable bcd_int : integer;
        variable row_idx : integer;
        variable col_idx : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                red   <= (others => '0');
                green <= (others => '0');
                blue  <= (others => '0');
            elsif ce = '1' then
                if video_on = '1' then
                    h_pos   := to_integer(unsigned(h_count));
                    v_pos   := to_integer(unsigned(v_count));
                    x_p     := to_integer(unsigned(x_pos));
                    y_p     := to_integer(unsigned(y_pos));
                    bcd_int := to_integer(unsigned(bcd_val));

                    red   <= "0000";
                    green <= "0000";
                    blue  <= "0000";

                    -- Only digits
                    if bcd_int > 9 then
                        bcd_int := 0;
                    end if;

                    -- Check if the current pixel is within bounding box
                    if (h_pos >= x_p) and (h_pos < x_p + 24) and
                        (v_pos >= y_p) and (v_pos < y_p + 48) then

                        row_idx := (bcd_int * 48) + (v_pos - y_p);
                        col_idx := 23 - (h_pos - x_p);

                        if FONT(row_idx)(col_idx) = '1' then
                            red   <= "1111";
                            green <= "1111";
                            blue  <= "1111";
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
end architecture behavioral;
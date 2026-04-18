library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity bin2bcd is
    port (
        bin   : in  std_logic_vector(7 downto 0);

        hundreds : out std_logic_vector(3 downto 0);
        tens     : out std_logic_vector(3 downto 0);
        ones     : out std_logic_vector(3 downto 0)
    );
end entity bin2bcd;

architecture behavioral of bin2bcd is
begin

    -- Double Dabble algorithm
    process(bin)
        variable temp : std_logic_vector(7 downto 0);
        variable bcd  : std_logic_vector(11 downto 0);
    begin
        temp := bin;
        bcd  := (others => '0');

        for i in 0 to 7 loop
            if unsigned(bcd(3 downto 0)) >= 5 then
                bcd(3 downto 0) := std_logic_vector(unsigned(bcd(3 downto 0)) + 3);
            end if;

            if unsigned(bcd(7 downto 4)) >= 5 then
                bcd(7 downto 4) := std_logic_vector(unsigned(bcd(7 downto 4)) + 3);
            end if;

            if unsigned(bcd(11 downto 8)) >= 5 then
                bcd(11 downto 8) := std_logic_vector(unsigned(bcd(11 downto 8)) + 3);
            end if;

            bcd := bcd(10 downto 0) & temp(7);
            temp := temp(6 downto 0) & '0';
        end loop;

        hundreds <= bcd(11 downto 8);
        tens     <= bcd(7 downto 4);
        ones     <= bcd(3 downto 0);

    end process;

end behavioral;
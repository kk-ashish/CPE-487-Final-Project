library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity kong_logic is
    Port (
        clk    : in STD_LOGIC;
        x_pos  : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos  : out STD_LOGIC_VECTOR(10 downto 0)
    );
end kong_logic;

architecture Behavioral of kong_logic is
    signal x        : unsigned(10 downto 0) := to_unsigned(60, 11);
    constant y_val  : unsigned(10 downto 0) := to_unsigned(50, 11);
    signal counter  : unsigned(19 downto 0) := (others => '0'); 
    signal dir      : STD_LOGIC := '1';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = to_unsigned(1000000, 20) then
                counter <= (others => '0');

                if counter(0) = '1' then
                    dir <= not dir;
                end if;

                if dir = '1' then
                    if x < to_unsigned(620, 11) then
                        x <= x + 4;
                    else
                        dir <= '0';
                    end if;
                else
                    if x > to_unsigned(10, 11) then
                        x <= x - 4;
                    else
                        dir <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    x_pos <= std_logic_vector(x);
    y_pos <= std_logic_vector(y_val);
end Behavioral;

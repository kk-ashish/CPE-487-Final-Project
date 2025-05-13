library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barrel_logic is
    Port (
        clk        : in STD_LOGIC;
        pixel_x    : in STD_LOGIC_VECTOR(10 downto 0);
        pixel_y    : in STD_LOGIC_VECTOR(10 downto 0);
        barrel_on  : out STD_LOGIC;
        x_pos0     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos0     : out STD_LOGIC_VECTOR(10 downto 0);
        x_pos1     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos1     : out STD_LOGIC_VECTOR(10 downto 0);
        x_pos2     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos2     : out STD_LOGIC_VECTOR(10 downto 0);
        x_pos3     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos3     : out STD_LOGIC_VECTOR(10 downto 0);
        x_pos4     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos4     : out STD_LOGIC_VECTOR(10 downto 0);
        x_pos5     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos5     : out STD_LOGIC_VECTOR(10 downto 0)
    );
end barrel_logic;

architecture Behavioral of barrel_logic is
    constant MAX_BARRELS    : integer := 6;
    constant BARREL_WIDTH   : integer := 12;
    constant BARREL_HEIGHT  : integer := 14;

    type barrel_record is record
        x       : STD_LOGIC_VECTOR(10 downto 0);
        y       : STD_LOGIC_VECTOR(10 downto 0);
        dir     : STD_LOGIC;
        counter : unsigned(19 downto 0);
    end record;

    type barrel_array is array(0 to MAX_BARRELS-1) of barrel_record;
    signal barrels : barrel_array := (
        0 => (x => std_logic_vector(to_unsigned(600, 11)), y => std_logic_vector(to_unsigned(73, 11)),  dir => '0', counter => (others => '0')),
        1 => (x => std_logic_vector(to_unsigned(500, 11)), y => std_logic_vector(to_unsigned(73, 11)),  dir => '1', counter => (others => '0')),
        2 => (x => std_logic_vector(to_unsigned(580, 11)), y => std_logic_vector(to_unsigned(153, 11)), dir => '0', counter => (others => '0')),
        3 => (x => std_logic_vector(to_unsigned(480, 11)), y => std_logic_vector(to_unsigned(153, 11)), dir => '1', counter => (others => '0')),
        4 => (x => std_logic_vector(to_unsigned(620, 11)), y => std_logic_vector(to_unsigned(233, 11)), dir => '0', counter => (others => '0')),
        5 => (x => std_logic_vector(to_unsigned(620, 11)), y => std_logic_vector(to_unsigned(313, 11)), dir => '1', counter => (others => '0'))
    );

begin
    -- Output each barrel position to top-level ports
    x_pos0 <= barrels(0).x;
    y_pos0 <= barrels(0).y;
    x_pos1 <= barrels(1).x;
    y_pos1 <= barrels(1).y;
    x_pos2 <= barrels(2).x;
    y_pos2 <= barrels(2).y;
    x_pos3 <= barrels(3).x;
    y_pos3 <= barrels(3).y;
    x_pos4 <= barrels(4).x;
    y_pos4 <= barrels(4).y;
    x_pos5 <= barrels(5).x;
    y_pos5 <= barrels(5).y;

    -- Movement process
    process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to MAX_BARRELS-1 loop
                barrels(i).counter <= barrels(i).counter + 1;
                if barrels(i).counter = to_unsigned(1000000, 20) then
                    barrels(i).counter <= (others => '0');

                    if barrels(i).dir = '1' then
                        if unsigned(barrels(i).x) < 628 then
                            barrels(i).x <= std_logic_vector(unsigned(barrels(i).x) + 1);
                        else
                            barrels(i).dir <= '0';
                        end if;
                    else
                        if unsigned(barrels(i).x) > 1 then
                            barrels(i).x <= std_logic_vector(unsigned(barrels(i).x) - 1);
                        else
                            barrels(i).dir <= '1';
                        end if;
                    end if;
                end if;
            end loop;
        end if;
    end process;

    -- drawing
    process(pixel_x, pixel_y, barrels)
    begin
        barrel_on <= '0';
        for i in 0 to MAX_BARRELS-1 loop
            if unsigned(pixel_x) >= unsigned(barrels(i).x) and unsigned(pixel_x) < unsigned(barrels(i).x) + BARREL_WIDTH and
               unsigned(pixel_y) >= unsigned(barrels(i).y) and unsigned(pixel_y) < unsigned(barrels(i).y) + BARREL_HEIGHT then
                barrel_on <= '1';
            end if;
        end loop;
    end process;

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity donkey_kong is
    Port (
        clk     : in STD_LOGIC;
        btnu    : in STD_LOGIC;
        btnd    : in STD_LOGIC;
        btnl    : in STD_LOGIC;
        btnr    : in STD_LOGIC;
        btnc    : in STD_LOGIC;
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;
        red     : out STD_LOGIC_VECTOR(3 downto 0);
        green   : out STD_LOGIC_VECTOR(3 downto 0);
        blue    : out STD_LOGIC_VECTOR(3 downto 0);
        led     : out STD_LOGIC_VECTOR(15 downto 0);
        anode   : out STD_LOGIC_VECTOR(7 downto 0);
        seg     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end donkey_kong;

architecture Behavioral of donkey_kong is

    component leddec16 is
        Port (
            dig   : in  STD_LOGIC_VECTOR(2 downto 0);
            data  : in  STD_LOGIC_VECTOR(15 downto 0);
            anode : out STD_LOGIC_VECTOR(7 downto 0);
            seg   : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal red_internal, green_internal, blue_internal : STD_LOGIC_VECTOR(3 downto 0);
    signal clk_25MHz : STD_LOGIC;
    signal pixel_x, pixel_y : STD_LOGIC_VECTOR(10 downto 0);

    signal mario_x, mario_y : STD_LOGIC_VECTOR(10 downto 0);
    signal kong_x, kong_y   : STD_LOGIC_VECTOR(10 downto 0);

    signal barrel_on : STD_LOGIC;
    type barrel_array_type is array(0 to 5) of STD_LOGIC_VECTOR(10 downto 0);
    signal barrel_x_array, barrel_y_array : barrel_array_type;

    signal is_platform, is_ladder : STD_LOGIC;
    signal reset : STD_LOGIC := '0';

    -- objective block
    signal objective_x : STD_LOGIC_VECTOR(10 downto 0) := std_logic_vector(to_unsigned(100, 11));
    constant OBJECTIVE_Y : STD_LOGIC_VECTOR(10 downto 0) := std_logic_vector(to_unsigned(45, 11));
    constant OBJECTIVE_WIDTH : integer := 10;
    constant OBJECTIVE_HEIGHT : integer := 10;

    signal rng_counter : unsigned(23 downto 0) := (others => '0');

    -- score tracking
    signal score : unsigned(15 downto 0) := (others => '0');
    signal score_display : STD_LOGIC_VECTOR(15 downto 0);
    signal count : unsigned(20 downto 0) := (others => '0');
    signal led_mpx : STD_LOGIC_VECTOR(2 downto 0);

begin

    clkgen: entity work.clk_wiz_0
        port map (
            clk_in1  => clk,
            clk_out1 => clk_25MHz
        );

    vga: entity work.vga_sync
        port map (
            pixel_clk  => clk_25MHz,
            red_in     => red_internal,
            green_in   => green_internal,
            blue_in    => blue_internal,
            red_out    => red,
            green_out  => green,
            blue_out   => blue,
            hsync      => hsync,
            vsync      => vsync,
            pixel_row  => pixel_y,
            pixel_col  => pixel_x
        );

    mario: entity work.mario_logic
        port map (
            clk        => clk_25MHz,
            btnu       => btnu,
            btnd       => btnd,
            btnl       => btnl,
            btnr       => btnr,
            btnc       => btnc,
            is_ladder  => is_ladder,
            reset      => reset,
            x_pos      => mario_x,
            y_pos      => mario_y
        );

    kong: entity work.kong_logic
        port map (
            clk   => clk_25MHz,
            x_pos => kong_x,
            y_pos => kong_y
        );

    barrels: entity work.barrel_logic
        port map (
            clk        => clk_25MHz,
            pixel_x    => pixel_x,
            pixel_y    => pixel_y,
            barrel_on  => barrel_on,
            x_pos0     => barrel_x_array(0),
            y_pos0     => barrel_y_array(0),
            x_pos1     => barrel_x_array(1),
            y_pos1     => barrel_y_array(1),
            x_pos2     => barrel_x_array(2),
            y_pos2     => barrel_y_array(2),
            x_pos3     => barrel_x_array(3),
            y_pos3     => barrel_y_array(3),
            x_pos4     => barrel_x_array(4),
            y_pos4     => barrel_y_array(4),
            x_pos5     => barrel_x_array(5),
            y_pos5     => barrel_y_array(5)
        );

    platform_draw: entity work.platforms_and_ladders
        port map (
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            is_platform => is_platform,
            is_ladder   => is_ladder
        );

    process(clk_25MHz)
    begin
        if rising_edge(clk_25MHz) then
            count <= count + 1;
            led_mpx <= std_logic_vector(count(20 downto 18));
        end if;
    end process;

    score_display <= std_logic_vector(score);
    led <= score_display;

    score_display_driver : leddec16
        port map (
            dig   => led_mpx,
            data  => score_display,
            anode => anode,
            seg   => seg
        );

    process(clk_25MHz)
    begin
        if rising_edge(clk_25MHz) then
            reset <= '0';

            -- collision check with barrels
            for i in 0 to 5 loop
                if unsigned(mario_x) + 16 > unsigned(barrel_x_array(i)) and unsigned(mario_x) < unsigned(barrel_x_array(i)) + 12 and
                   unsigned(mario_y) + 24 > unsigned(barrel_y_array(i)) and unsigned(mario_y) < unsigned(barrel_y_array(i)) + 14 then
                    reset <= '1';
                    score <= (others => '0');
                end if;
            end loop;

            -- collision check with the objective
            if unsigned(mario_x) + 16 > unsigned(objective_x) and unsigned(mario_x) < unsigned(objective_x) + OBJECTIVE_WIDTH and
               unsigned(mario_y) + 24 > unsigned(OBJECTIVE_Y) and unsigned(mario_y) < unsigned(OBJECTIVE_Y) + OBJECTIVE_HEIGHT then
                reset <= '1';
                rng_counter <= rng_counter + 12345;
                objective_x <= std_logic_vector(rng_counter(10 downto 0));
                score <= score + 1;
            end if;

            -- collision check with donkey kong
            if unsigned(mario_x) + 16 > unsigned(kong_x) and unsigned(mario_x) < unsigned(kong_x) + 24 and
               unsigned(mario_y) + 24 > unsigned(kong_y) and unsigned(mario_y) < unsigned(kong_y) + 36 then
                reset <= '1';
                score <= (others => '0');
            end if;
        end if;
    end process;

    red_internal <= "1111" when unsigned(pixel_x) >= unsigned(mario_x) and unsigned(pixel_x) < unsigned(mario_x) + 16 and
                             unsigned(pixel_y) >= unsigned(mario_y) and unsigned(pixel_y) < unsigned(mario_y) + 24 else
                    "1010" when is_platform = '1' else
                    "0000";

    green_internal <= "1111" when barrel_on = '1' else
                       "1111" when is_ladder = '1' else
                       "0000";

    blue_internal <= "1111" when unsigned(pixel_x) >= unsigned(kong_x) and unsigned(pixel_x) < unsigned(kong_x) + 24 and
                              unsigned(pixel_y) >= unsigned(kong_y) and unsigned(pixel_y) < unsigned(kong_y) + 36 else
                     "1111" when unsigned(pixel_x) >= unsigned(objective_x) and unsigned(pixel_x) < unsigned(objective_x) + OBJECTIVE_WIDTH and
                              unsigned(pixel_y) >= unsigned(OBJECTIVE_Y) and unsigned(pixel_y) < unsigned(OBJECTIVE_Y) + OBJECTIVE_HEIGHT else
                     "0000";

end Behavioral;
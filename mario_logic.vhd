library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mario_logic is
    Port (
        clk       : in STD_LOGIC;
        btnu      : in STD_LOGIC;
        btnd      : in STD_LOGIC;
        btnl      : in STD_LOGIC;
        btnr      : in STD_LOGIC;
        btnc      : in STD_LOGIC;
        is_ladder : in STD_LOGIC;
        reset     : in STD_LOGIC;
        x_pos     : out STD_LOGIC_VECTOR(10 downto 0);
        y_pos     : out STD_LOGIC_VECTOR(10 downto 0)
    );
end mario_logic;

architecture Behavioral of mario_logic is
    constant MARIO_WIDTH  : integer := 16;
    constant MARIO_HEIGHT : integer := 24;
    constant JUMP_FORCE   : integer := 9;
    constant GROUND_Y     : integer := 435;

    signal x      : STD_LOGIC_VECTOR(10 downto 0) := conv_std_logic_vector(60, 11);
    signal y      : STD_LOGIC_VECTOR(10 downto 0) := conv_std_logic_vector(GROUND_Y, 11);
    signal jumping    : boolean := false;
    signal counter : STD_LOGIC_VECTOR(20 downto 0) := (others => '0');

    type platform_array is array(0 to 5) of integer;
    constant platform_levels : platform_array := (75, 155, 235, 315, 395, 435);

    signal jump_height : integer := 0;
    signal y_dir : integer := 0; -- 0 = none, -1 = up, 1 = down
begin
    process(clk)
        variable y_int : integer;
        variable x_int : integer;
        variable i     : integer;
        variable touching_ladder : boolean := false;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                x <= conv_std_logic_vector(60, 11);
                y <= conv_std_logic_vector(GROUND_Y, 11);
                jumping <= false;
                y_dir <= 0;
                jump_height <= 0;
            else
                counter <= counter + 1;
                if counter = 0 then
                    x_int := conv_integer(x);
                    y_int := conv_integer(y);

                    -- horizontal movement
                    if btnr = '1' and x_int < 640 - MARIO_WIDTH then
                        x <= x + 4;
                    elsif btnl = '1' and x_int > 0 then
                        x <= x - 4;
                    end if;

                    -- jump trigger
                    if btnc = '1' and not jumping then
                        jumping <= true;
                        jump_height <= 0;
                        y_dir <= -1;
                    end if;

                    -- jumping behavior
                    if jumping then
                        if y_dir = -1 then
                            y_int := y_int - 4;
                            jump_height <= jump_height + 4;
                            if jump_height >= JUMP_FORCE * 4 then
                                y_dir <= 1;
                            end if;

                        elsif y_dir = 1 then
                            y_int := y_int + 4;

                            -- snapping to platforms
                            for i in 0 to 5 loop
                                if (y_int + MARIO_HEIGHT >= platform_levels(i)) and (y_int + MARIO_HEIGHT - 4 < platform_levels(i)) then
                                    y_int := platform_levels(i) - MARIO_HEIGHT;
                                    jumping <= false;
                                    y_dir <= 0;
                                end if;
                            end loop;

                            -- Ground landing
                            if y_int + MARIO_HEIGHT >= GROUND_Y then
                                y_int := GROUND_Y - MARIO_HEIGHT;
                                jumping <= false;
                                y_dir <= 0;
                            end if;
                        end if;
                    end if;

                    -- ladder region check
                    touching_ladder := (
                        ((x_int + MARIO_WIDTH >= 100 and x_int <= 105) and (y_int + MARIO_HEIGHT >= 75 and y_int <= 165)) or
                        ((x_int + MARIO_WIDTH >= 500 and x_int <= 505) and (y_int + MARIO_HEIGHT >= 155 and y_int <= 245)) or
                        ((x_int + MARIO_WIDTH >= 100 and x_int <= 105) and (y_int + MARIO_HEIGHT >= 235 and y_int <= 325)) or
                        ((x_int + MARIO_WIDTH >= 500 and x_int <= 505) and (y_int + MARIO_HEIGHT >= 315 and y_int <= 440))
                    );

                    -- climbing
                    if touching_ladder then
                        if btnu = '1' then
                            y_int := y_int - 4;
                            jumping <= false;
                            y_dir <= 0;
                        elsif btnd = '1' then
                            y_int := y_int + 4;
                            jumping <= false;
                            y_dir <= 0;
                        end if;

                        -- snap feet when aligned
                        for i in 0 to 5 loop
                            if (y_int + MARIO_HEIGHT) >= platform_levels(i) and (y_int + MARIO_HEIGHT) <= platform_levels(i) + 1 then
                                y_int := platform_levels(i) - MARIO_HEIGHT;
                            end if;
                        end loop;
                    end if;

                    y <= conv_std_logic_vector(y_int, 11);
                end if;
            end if;
        end if;
    end process;

    x_pos <= x;
    y_pos <= y;
end Behavioral;




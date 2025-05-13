library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity platforms_and_ladders is
Port (
    pixel_x     : in STD_LOGIC_VECTOR(10 downto 0);
    pixel_y     : in STD_LOGIC_VECTOR(10 downto 0);
    is_platform : out STD_LOGIC;
    is_ladder   : out STD_LOGIC
);

end platforms_and_ladders;

architecture Behavioral of platforms_and_ladders is
begin
    process(pixel_x, pixel_y)
    begin
        is_platform <= '0';
        is_ladder   <= '0';
    
        -- platforms
        if (pixel_y >= 80 and pixel_y <= 85) then
            is_platform <= '1'; 
        elsif (pixel_y >= 160 and pixel_y <= 165) then
            is_platform <= '1'; 
        elsif (pixel_y >= 240 and pixel_y <= 245) then
            is_platform <= '1';
        elsif (pixel_y >= 320 and pixel_y <= 325) then
            is_platform <= '1';
        elsif (pixel_y >= 440 and pixel_y <= 479) then
            is_platform <= '1';
        end if;
    
        -- ladders
        if (pixel_x >= 100 and pixel_x <= 105) and (pixel_y >= 80 and pixel_y <= 165) then
            is_ladder <= '1';
        elsif (pixel_x >= 500 and pixel_x <= 505) and (pixel_y >= 160 and pixel_y <= 245) then
            is_ladder <= '1';
        elsif (pixel_x >= 100 and pixel_x <= 105) and (pixel_y >= 240 and pixel_y <= 325) then
            is_ladder <= '1';
        elsif (pixel_x >= 500 and pixel_x <= 505) and (pixel_y >= 320 and pixel_y <= 440) then
            is_ladder <= '1';
        end if;
    end process;

end Behavioral;

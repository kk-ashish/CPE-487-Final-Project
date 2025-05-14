# Donkey Kong FPGA Game - CPE 487 Final Project

## Description
This project recreates the classic Donkey Kong-style platformer game on the **Nexys A7-100T FPGA board** using VHDL. The game is rendered on a VGA monitor and features:

- A controllable Mario character
- Moving barrels that Mario must avoid
- A randomly-placed objective block that Mario must reach to gain points
- A static Donkey Kong character as a hazard
- Real-time score display on the **7-segment LED display**

### Objective
The player must guide Mario to collect as many objectives as possible while avoiding the barrels and Donkey Kong. 
- **Touching a barrel or Donkey Kong resets Mario and the score**
- **Touching the objective resets Mario's position and increases the score by 1**

### Controls
- BTNU: Mario climb up ladder
- BTND: Mario CLimb down ladder
- BTNL: Mario move left
- BTNR: Mario move right
- BTNC: Makes Mario jump

## Required Hardware
- Nexys A7-100T FPGA Board
- VGA Monitor & VGA Cable
- 7-segment LED display on board

## Images / Diagrams

#### Gameplay Screenshot
ADD VIDEO HERE

#### Module Diagram
ADD DIAGRAM HERE

## Steps to Run
1. **Download all VHDL and .xdc files** from this repo
2. **Create a new Vivado project** for the Nexys A7-100T
3. **Add Sources:**
   - `donkey_kong.vhd`
   - `mario_logic.vhd`
   - `kong_logic.vhd`
   - `barrel_logic.vhd`
   - `leddec16.vhd`
   - `vga_sync.vhd`
   - `platforms_and_ladders.vhd`
   - `clk_wiz_0.vhd`, `clk_wiz_0_clk_wiz.vhd`
4. **Add Constraints File:** `donkey_kong.xdc`
5. **Run Synthesis**
6. **Run Implementation**
7. **Generate Bitstream**
8. **Open Hardware Manager** and **Program the Device**

## Inputs & Outputs
### donkey_kong.vhd
#### Inputs
- `clk`: System clock (100 MHz)
- `btnu`, `btnd`, `btnl`, `btnr`, `btnc`: Navigation buttons

#### Outputs
- `red`, `green`, `blue`, `hsync`, `vsync`: VGA output signals
- `led`: Debug (also mirrors score)
- `anode`, `seg`: 7-segment display outputs for real-time score
---
### mario_logic.vhd
#### Inputs
```vhdl
clk       : in STD_LOGIC;
btnu      : in STD_LOGIC;
btnd      : in STD_LOGIC;
btnl      : in STD_LOGIC;
btnr      : in STD_LOGIC;
btnc      : in STD_LOGIC;
is_ladder : in STD_LOGIC;
reset     : in STD_LOGIC;
```
- `clk`: 25 MHz pixel clock
- `btnu/btnd/btnl/btnr`: Directional controls
- `btnc`: Center button for jump
- `is_ladder`: Indicates if Mario is over a ladder
- `reset`: Triggers Mario's position reset

#### Outputs
```vhdl
x_pos     : out STD_LOGIC_VECTOR(10 downto 0);
y_pos     : out STD_LOGIC_VECTOR(10 downto 0)
```
- `x_pos`, `y_pos`: Mario's current screen coordinates

---
### kong_logic.vhd
#### Inputs
```vhdl
clk    : in STD_LOGIC;
```
- `clk`: 25 MHz pixel clock
- 
#### Outputs
```vhdl
x_pos  : out STD_LOGIC_VECTOR(10 downto 0);
y_pos  : out STD_LOGIC_VECTOR(10 downto 0);
```
- Static position of Donkey Kong on the screen

---
### barrel_logic.vhd
#### Inputs
```vhdl
clk        : in STD_LOGIC;
pixel_x    : in STD_LOGIC_VECTOR(10 downto 0);
pixel_y    : in STD_LOGIC_VECTOR(10 downto 0);
```
- `clk`: 25 MHz pixel clock
- `pixel_x`, `pixel_y`: VGA scan position for rendering

#### Outputs
```vhdl
barrel_on  : out STD_LOGIC;
x_pos0..5  : out STD_LOGIC_VECTOR(10 downto 0);
y_pos0..5  : out STD_LOGIC_VECTOR(10 downto 0);
```
- `barrel_on`: Active if barrel should be drawn
- `x_posN/y_posN`: Position of barrel N

---
### platforms_and_ladders.vhd
#### Inputs
```vhdl
pixel_x     : in STD_LOGIC_VECTOR(10 downto 0);
pixel_y     : in STD_LOGIC_VECTOR(10 downto 0);
```
- `pixel_x/pixel_y`: Current pixel position

#### Outputs
```vhdl
is_platform : out STD_LOGIC;
is_ladder   : out STD_LOGIC;
```
- Flags for whether the pixel is part of a platform or ladder

---
### leddec16.vhd
#### Inputs
```vhdl
dig  : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
```
- `dig`: Selects which of 4 digits to enable
- `data`: Score to display across 4 digits

#### Outputs
```vhdl
anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
seg   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
```
- `anode`: Active-low anode control for each digit
- `seg`: Segment pattern for current digit

## Modifications Made
This project was built from scratch using base components from earlier labs (mostly Lab 6: Pong). Key contributions:
***```donkey_kong.vhd```***
  ```
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
  ```

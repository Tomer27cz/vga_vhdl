library ieee;
use ieee.std_logic_1164.all;

package const_pkg is
----------------------------------------------------------------
-- General  Constants
----------------------------------------------------------------

-- Frames to wait before allowing ball movement
constant INITIAL_RESET_DELAY  : integer := 180; -- 3 seconds at 60Hz
constant SCORE_DELAY_FRAMES   : integer := 60;  -- 1 second at 60Hz

----------------------------------------------------------------
--  AI Constants
----------------------------------------------------------------
constant C_AI_DEADZONE   : integer := 10;

----------------------------------------------------------------
-- Screen & Object Constants
----------------------------------------------------------------
constant C_PADDLE_WIDTH  : integer := 10;
constant C_PADDLE_HEIGHT : integer := 60;
constant C_BALL_SIZE     : integer := 10;

-- X positions for paddles are fixed
constant C_P1_X          : integer := 20;   -- Left side
constant C_P2_X          : integer := 610;  -- Right side

-- Speeds (Pixels moved per frame)
constant C_PADDLE_SPEED  : integer := 5;
constant C_BALL_SPEED_X  : integer := 4;
constant C_BALL_SPEED_Y  : integer := 4;

----------------------------------------------------------------
-- Physics/Bounce Constants
----------------------------------------------------------------
-- Distance from center of paddle to trigger different bounce angles
constant C_BOUNCE_THRESH_LARGE : integer := 15;
constant C_BOUNCE_THRESH_SMALL : integer := 5;

-- Resulting Y-velocities based on hit location
constant C_BOUNCE_VEL_FAST     : integer := 4;
constant C_BOUNCE_VEL_SLOW     : integer := 2;
constant C_BOUNCE_VEL_FLAT     : integer := 0;

----------------------------------------------------------------
-- Score Constants
----------------------------------------------------------------
constant C_SCORE_Y       : integer := 16;

-- Player 1 Score X Positions (expanding left from center)
constant C_SCORE_P1_POS1 : integer := 256; -- Closest to center line
constant C_SCORE_P1_POS2 : integer := 224;
constant C_SCORE_P1_POS3 : integer := 192; -- Furthest left

-- Player 2 Score X Positions (expanding right from center)
constant C_SCORE_P2_POS1 : integer := 360; -- Closest to center line
constant C_SCORE_P2_POS2 : integer := 392;
constant C_SCORE_P2_POS3 : integer := 424; -- Furthest right

----------------------------------------------------------------
-- VGA Sync Constants
----------------------------------------------------------------
-- 640x480 @ 60Hz timings (Pixel Clock = 25 MHz)
constant H_DISPLAY : integer := 640;                              -- Active video pixels per line
constant H_FP      : integer := 16;                               -- Front porch (pixels)
constant H_SYNC    : integer := 96;                               -- Sync pulse width (pixels)
constant H_BP      : integer := 48;                               -- Back porch (pixels)
constant H_TOTAL   : integer := H_DISPLAY + H_FP + H_SYNC + H_BP; -- 800

constant V_DISPLAY : integer := 480;                              -- Active video lines per frame
constant V_FP      : integer := 10;                               -- Front porch (lines)
constant V_SYNC    : integer := 2;                                -- Sync pulse width (lines)
constant V_BP      : integer := 33;                               -- Back porch (lines)
constant V_TOTAL   : integer := V_DISPLAY + V_FP + V_SYNC + V_BP; -- 525

end package const_pkg;
# PONG_DRAW Component

Translates game state into RGB signals. 
By comparing the current pixel coordinates (`h_count`, `v_count`) against object boundaries, it determines the appropriate pixel colors to output to the screen.

## Interface - [pong_draw.vhd](../components/pong_draw/src/pong_draw.vhd)

| Port Name   | Dir | Type                            | Description                              |
|:------------|:---:|:--------------------------------|:-----------------------------------------|
| `clk`       | In  | `std_logic`                     | System clock.                            |
| `rst`       | In  | `std_logic`                     | Asynchronous reset.                      |
| `ce`        | In  | `std_logic`                     | Clock enable.                            |
| `h_count`   | In  | `std_logic_vector (9 downto 0)` | Current pixel X coordinate (from VGA).   |
| `v_count`   | In  | `std_logic_vector (9 downto 0)` | Current pixel Y coordinate (from VGA).   |
| `video_on`  | In  | `std_logic`                     | Active high in the visible display area. |
| `paddle1_y` | In  | `std_logic_vector (9 downto 0)` | Player 1 (left) paddle Y coordinate.     |
| `paddle2_y` | In  | `std_logic_vector (9 downto 0)` | Player 2 (right) paddle Y coordinate.    |
| `ball_x`    | In  | `std_logic_vector (9 downto 0)` | Ball X coordinate.                       |
| `ball_y`    | In  | `std_logic_vector (9 downto 0)` | Ball Y coordinate.                       |
| `red`       | Out | `std_logic_vector (3 downto 0)` | 4-bit red channel output.                |
| `green`     | Out | `std_logic_vector (3 downto 0)` | 4-bit green channel output.              |
| `blue`      | Out | `std_logic_vector (3 downto 0)` | 4-bit blue channel output.               |

## Rendering Logic

Rendering is synchronous with `clk`, enabled by `ce`, and active only when `video_on = '1'`. 
To ensure proper visual overlap, elements are drawn in the following Z-order (bottom to top):

1.  **Background:** Black (`0000`, `0000`, `0000`) default fallback.
2.  **Center Line:** Dashed gray (`0100`, `0100`, `0100`). Dashed effect derived via `v_pos mod 16 < 8`.
3.  **Paddles:** Solid white (`1111`, `1111`, `1111`) at fixed X offsets and dynamic Y inputs.
4.  **Ball (Top Layer):** Solid yellow (`1111`, `1111`, `0000`). Rendered last to correctly overlap the center line.

**Blanking Intervals:** When `video_on = '0'`, all RGB outputs must be driven to zero (`0000`) to comply with standard VGA timing and prevent monitor desynchronization.

## Test Bench - [pong_draw_tb.vhd](../components/pong_draw/sim/pong_draw_tb.vhd)

![pong_draw_tb](img/pong_draw/pong_draw_tb.png)
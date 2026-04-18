# PONG_AI Component

The `pong_ai` component serves as an automated opponent for the Pong game.
It calculates the difference between the ball and the paddle, then sends commands to keep the paddle aligned with the ball.

## Interface - [pong_ai.vhd](../components/pong_ai/src/pong_ai.vhd)

| Port Name     | Direction | Type                            | Description                                                |
|:--------------|:---------:|:--------------------------------|:-----------------------------------------------------------|
| `clk`         |   Input   | `std_logic`                     | Main system clock.                                         |
| `rst`         |   Input   | `std_logic`                     | Resets the AI outputs to their default state.              |
| `ce_60hz`     |   Input   | `std_logic`                     | Clock enable pulse (60 Hz) to synchronize with physics.    |
| `ball_y`      |   Input   | `std_logic_vector (9 downto 0)` | Current Y coordinate of the ball.                          |
| `paddle_y`    |   Input   | `std_logic_vector (9 downto 0)` | Current Y coordinate of the AI's paddle.                   |
| `paddle_up`   |  Output   | `std_logic`                     | Output signal simulating a player pressing "Up".           |
| `paddle_down` |  Output   | `std_logic`                     | Output signal simulating a player pressing "Down".         |

## Functionality

The `pong_ai` component tracks the ball and moves the paddle continuously. It evaluates the game state on every `ce_60hz` clock enable:

* **Center Calculation:** Calculates the vertical center of both the ball (`sig_ball_center_y`) and the paddle (`sig_paddle_center_y`).
* **Deadzone Logic:** To prevent the paddle from "jittering" when it is almost aligned with the ball, a deadzone (`C_AI_DEADZONE`) is implemented.
* **Movement Execution:** 
    * If the ball's center is above the paddle's deadzone, `paddle_up` is turned on.
    * If the ball's center is below the paddle's deadzone, `paddle_down` is turned on.
    * If the ball is within the deadzone, both signals are turned off.

*(Constants for this component are defined in [const_pkg.vhd](../components/common/const_pkg.vhd))*

## Logic Diagram

```mermaid
flowchart TD
    START([Rising Edge: clk]) --> RST{"rst = '1'?"}
    RST -- Yes --> RESET_STATE["paddle_up = '0'\npaddle_down = '0'"]
    RST -- No --> CE{"ce_60hz = '1'?"}
    
    CE -- No --> IDLE([Hold State])
    CE -- Yes --> COMP{"Compare Y Centers"}
    
    COMP -->|Ball < Paddle - Deadzone| MOVE_UP["paddle_up = '1'\npaddle_down = '0'"]
    COMP -->|Ball > Paddle + Deadzone| MOVE_DOWN["paddle_up = '0'\npaddle_down = '1'"]
    COMP -->|Inside Deadzone| STOP["paddle_up = '0'\npaddle_down = '0'"]
    
    RESET_STATE --> END([End Process])
    MOVE_UP --> END
    MOVE_DOWN --> END
    STOP --> END
```

## Test Bench - [pong_ai_tb.vhd](../components/pong_ai/sim/pong_ai_tb.vhd)

![pong_ai_tb](img/pong_ai/pong_ai_tb.png)
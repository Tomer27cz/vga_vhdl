# vga_vhdl

### Team members:

- [Tomáš Lohynksý](https://github.com/Tomer27cz) (270965) - Team leader, responsible for the overall design and integration
- [Jan Tříletý](https://github.com/TriletyJ) (270374) - README documentation, poster, and presentation preparation

### Description:

This project is a VHDL implementation of a VGA controller. 

The controller generates the necessary signals to drive a VGA display, 
including horizontal and vertical synchronization signals, as well as the RGB color signals.

The project includes test benches to verify the functionality of the components.

### Components:

- [vga_sync](.github/VGA_SYNC.md): Generates the horizontal and vertical synchronization signals
- `img_gen`: Generates a test pattern to be displayed on the VGA screen (SMPTE Color Bars)
- `pong_physics`: Implements the physics for a simple Pong game, including ball movement and collision detection
- `pong_draw`: Generates the RGB signals to display the Pong game on the VGA screen

### Test benches:

- `vga_sync_tb`: Test bench for the `vga_sync` component
- `img_gen_tb`: Test bench for the `img_gen` component
- `pong_physics_tb`: Test bench for the `pong_physics` component
- `pong_draw_tb`: Test bench for the `pong_draw` component

### Top level modules:

- `pattern_only`: A top-level module that connects the `vga_sync` and `img_gen` components to display the test pattern on the VGA screen
- `pong_only`: A top-level module that connects the `vga_sync`, `pong_physics`, and `pong_draw` components to display the Pong game on the VGA screen
- `vga_top`: A top-level module that can be configured to display either the test pattern or the Pong game based on a control signal


### Schematic:

#### Pattern Only Top Level Schematic:

![Schematic img](.github/img/pattern_top_schematic.png)

#### Pong Only Top Level Schematic:

![Schematic img](.github/img/pong_top_schematic.png)











# RoverApp

## Description
Sample Rover app using OTP.

## Commands
```
Steps to run Rover simulator 
1. iex -S mix
2. RoverApp.Simulator.init_rover(1, {x, y} \\ {0,0})
3. RoverApp.Simulator.move_rover_up(1)
4. RoverApp.Simulator.move_rover_down(1)
5. RoverApp.Simulator.move_rover_left(1)
6. RoverApp.Simulator.move_rover_right(1)
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rover_app` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rover_app, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rover_app](https://hexdocs.pm/rover_app).


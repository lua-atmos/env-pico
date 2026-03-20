# atmos.env.pico

A [lua-atmos](../../../) environment for [pico-sdl-lua][1].

# Run

```
lua5.4 <lua-path>/atmos/env/pico/exs/click-drag-cancel.lua
```

# Events

- TODO

[1]: https://github.com/fsantanna/pico-sdl/tree/main/lua

# Source

Assumes this directory structure:

```
.
├── atmos/
├── env-pico/   <-- we are here
└── f-streams/
```

```bash
LUA_PATH="../f-streams/?/init.lua;../atmos/?.lua;../atmos/?/init.lua;;" lua5.4 exs/across.lua
```

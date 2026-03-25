# atmos-env-pico

An [Atmos][atmos] environment for [pico-sdl][pico-sdl].

[atmos]:    https://github.com/lua-atmos/atmos/
[pico-sdl]: https://github.com/fsantanna/pico-sdl/tree/main/lua

# Install

```
sudo luarocks --lua-version=5.4 install atmos-env-pico
```

# Run

```
lua5.4 <lua-path>/atmos/env/pico/exs/click-drag-cancel.lua
```

# Events

- `clock`
- `'draw'`
- `'quit'`
- `'key'` (key down/up, with key name matching)
- `'mouse.button'` (button down/up, with button name matching)
- other pico-sdl input events

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

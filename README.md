# atmos-env-pico

An [Atmos][atmos] environment for [pico-sdl][pico-sdl].

[atmos]:    https://github.com/lua-atmos/atmos/
[pico-sdl]: https://github.com/fsantanna/pico-sdl/tree/main/lua

[
    [`v0.3`](https://github.com/lua-atmos/env-pico/tree/v0.3)  |
    [`v0.2`](https://github.com/lua-atmos/env-pico/tree/v0.2)  |
    [`v0.1`](https://github.com/lua-atmos/env-pico/tree/v0.1)
]

Stable branch is [`v0.3`](https://github.com/lua-atmos/env-pico/tree/v0.3).

# Install & Run

## Luarocks

```
sudo luarocks --lua-version=5.4 install atmos-env-pico
lua5.4 <lua-path>/atmos/env/pico/exs/click-drag-cancel.lua
```

- Dependencies: `pico-sdl v0.6`, `atmos v0.7`

## Development

From `luarocks.org`:

```
sudo luarocks --lua-version=5.4 install --dev atmos-env-pico
```

From local repo:

```
sudo luarocks make atmos-env-pico-dev-1.rockspec
```

# Events

- clock (`'clock'`, `us`)
- `'draw'`
- `'quit'`
- pico-sdl events:
    - `await{ tag='key.dn', key='Escape' }`
    - `await{ tag='mouse.button.dn', left=true }`
    - `await 'mouse.motion'`
    - filter: `await{ tag='until', 'mouse.button.dn', pred }`

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

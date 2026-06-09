# Plan: Release env-pico v0.3 (atmos v0.7)

## Context

`env-pico` must move to atmos v0.7. The SDL env (`env-sdl`) is
already migrated and is the reference; pico mirrors it with two
differences:

1. pico events use HIERARCHICAL STRING tags (`'mouse.button.dn'`,
   `'key.dn'`, `'mouse.motion'`, `'draw'`, `'quit'`), already on
   `e.tag`.
2. `M.is` (atmos run.lua:95) does prefix matching:
   - string vs string: `v` starts with `x..'.'`
   - table-event vs string: `e.tag` starts with `x`
   So bare-string awaits STILL WORK in v0.7
   (`await('mouse.button.dn')`, `every('draw')`). Only
   multi-arg awaits and the clock/emit signatures change.

VERSION: this is `v0.3`, NOT v0.2. `v0.2` is ALREADY RELEASED
(branch `v0.2`, `atmos >= 0.6`, pico-sdl v0.5 bump,
`atmos-env-pico-0.2-1.src.rock` packed). The atmos-v0.7
release gets a fresh `v0.3` + `atmos-env-pico-0.3-1.rockspec`.

v0.7 breaking changes (recap):
- Env API: `open`+`close` -> main body + `quit`
- `emit`/`await` single-arg only
- Clock: bare number in microseconds (no `'clock'` tag, no
  `clock{...}`); constants `_us_ _ms_ _s_ _min_ _h_ _day_`
- Custom matching via core table patterns + `until`/`while`
  (drop the `__atmos` metamethod)

Partial state ALREADY present (on `v0.2`/working tree):
- `init.lua` runs `pico.init(true)` at top-level (open->body
  ALREADY done).
- Source still has OLD event model (`M.close`, `__atmos`,
  `emit('clock', ms, M.now)`) -> must migrate.

This plan uses release branches (not tags) for versioning.

## Steps

### 0. Branch

- [ ] Create branch `v0.3` from current `main`/`v0.2` work

### 1. Migrate `init.lua`

| place | v0.6 | v0.7 |
|-------|------|------|
| `pico.init(true)` (L12) | top-level | keep (already body) |
| `M.close` (L15) | `function M.close()` | rename -> `function M.quit()` |
| clock (L53) | `emit('clock', ms, M.now)` | `emit(ms * 1000)` (ms -> us); keep `M.now` |
| event (L57) | `emit(setmetatable(e, meta))` | `emit(e)` (e already has `.tag`) |
| `meta`/`__atmos` (L19-42) | custom matcher | DELETE (use core matching) |
| `emit('draw')` (L63) | string tag | keep (valid) |

- [x] Rename `M.close` -> `M.quit`
- [x] Clock: `emit(ms * 1000)` (VERIFIED `ms` is ms via
      pico_native debug syms: `ms`/`dt`/`now` + `SDL_GetTicks`)
- [x] Event: `emit(e)`; delete `meta`/`__atmos`
- [x] Confirm `atmos.env(M)` registers (`step`/`quit`/`mode`)

#### 1.1 Await/event forms after dropping `__atmos`

The old `__atmos` did: tag prefix match + `key`/`mouse.button`
string field + optional trailing predicate. Replace with:

| old (multi-arg) | v0.7 single-arg |
|-----------------|-----------------|
| `await('mouse.motion')` | unchanged (bare string, prefix match) |
| `await('mouse.button.dn', fn)` | `await{ tag='until', 'mouse.button.dn', fn }` |
| `await('key.dn', 'Escape')` | `await{ tag='key.dn', key='Escape' }` |
| mouse button string `('mouse.button','left')` | `await{ tag='mouse.button.dn', left=true }` |
| `every('draw', fn)` | unchanged |

Rationale: core table match (run.lua:612-625) checks
`M.is(e.tag, pat.tag)` + `M.is(e[k], v)` per field;
`until` (run.lua:514-538) re-awaits a pattern until the
predicate holds.

### 2. Migrate examples (`exs/`)

| file | change |
|------|--------|
| `exs/hello.lua` | `clock{s=5}` -> `5*_s_`; `clock{ms=500}` -> `500*_ms_` |
| `exs/across.lua` | `await(clock{ms=50})` -> `await(50*_ms_)`; `every('draw',...)` stays |
| `exs/click-drag-cancel.lua` | `await('mouse.button.dn', fn)` -> `await{tag='until','mouse.button.dn',fn}`; `await('key.dn','Escape')` -> `await{tag='key.dn', key='Escape'}`; `every('mouse.motion',fn)` & `every('draw',fn)` stay |

- [ ] `exs/hello.lua`
- [ ] `exs/across.lua`
- [ ] `exs/click-drag-cancel.lua`

### 3. README.md

- [ ] Update any inline example syntax (clock/await)
- [ ] Confirm atmos version references (note: install line has
      no version pin; verify "Environments"/usage prose)

### 4. Rockspec

Create NEW `atmos-env-pico-0.3-1.rockspec` (copy `0.2-1`):

| field | v0.2 (released) | v0.3 |
|-------|-----------------|------|
| `version` | `0.2-1` | `0.3-1` |
| `source.branch` | `v0.2` | `v0.3` |
| `dependencies` atmos | `atmos >= 0.6` | `atmos ~> 0.7` |
| `pico-sdl` | `>= 0.5` | keep (verify required version) |

- [ ] Create `atmos-env-pico-0.3-1.rockspec`
- [ ] Verify module list (init + 3 exs)

### 5. Phase 1 tests (local, `LUA_PATH` trick)

- [ ] `exs/hello.lua`
- [ ] `exs/across.lua`
- [ ] `exs/click-drag-cancel.lua`

### 6. Phase 2 tests (global, `luarocks make`)

- [ ] `sudo luarocks make atmos-env-pico-0.3-1.rockspec`
- [ ] `exs/hello.lua`
- [ ] `exs/across.lua`
- [ ] `exs/click-drag-cancel.lua`

### 7. Commit, push, branch

- [ ] Commit, push `main`
- [ ] Create/update branch `v0.3`, push

### 8. Dependent apps (separate repos)

Apply the SAME transformations to each app (OUTSIDE this
worktree — edit on their repos):

Transformation rules (per file):
1. clock: `clock{s=N}` -> `N*_s_`; `clock{ms=N}` -> `N*_ms_`
   (`clock{ms=dt}` -> `dt*_ms_`)
2. predicate await: `await('tag', fn)` ->
   `await{ tag='until', 'tag', fn }`
3. field await: `await('key.dn', 'Escape')` ->
   `await{ tag='key.dn', key='Escape' }`
4. bare-string `await('x')` / `every('x', fn)`: UNCHANGED
5. their rockspec dep: `atmos-env-pico ~> 0.3`, `atmos ~> 0.7`
   (check each app's own next version number)

Apps:
- [ ] `pico-birds` (`birds-11.lua` + rockspec)
- [ ] `pico-rocks` (`main.lua` + rockspec)

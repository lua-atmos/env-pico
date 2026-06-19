# Plan: Re-release env-pico v0.3 (atmos 0.7-2)

## RESUME HERE (state @ 2026-06-18) -- NEXT = §3 test local

DONE so far: §1 migrate (5 sites) + §2 grep clean.
Source `exs/` is now on the 0.7-2 idiom; nothing else touched.
Resuming on another machine -> see "Resume checklist" below.

### Resume checklist (do in order)

PREREQ (blocker for §3, §5): the env-pico worktree needs
atmos `0.7-2` INSTALLED, but the box may still have `0.7-1`.
Verify + install:
- check: `grep -l loop_on $(luarocks which atmos | ...)` OR
  `lua5.4 -e 'require"atmos"; print(loop_on)'` (nil => old)
- the new core lives in sibling repo `../atmos`, branch `v0.7`
  (`atmos-0.7-2.rockspec` present). Install it:
  `cd ../atmos && sudo luarocks make atmos-0.7-2.rockspec`
- also needs `pico-sdl ~> 0.6` already installed (unchanged)

Then continue at §3.

PRIOR CUT (frozen, see bottom): env-pico v0.3 / rock `0.3-1`
was released for atmos 0.7-1. That work stands. Since then
atmos v0.7 grew BREAKING changes (shipping as 0.7-2):
`every`->`loop_on`, `task()` me-accessor -> `xtask()`,
`spawn(fn)` -> `do_spawn`. This re-cuts env-pico on the new
core.

Breaking sites (scan @ 2026-06-18):
- `exs/hello.lua:6` `every(500*_ms_, ...)`
- `exs/across.lua:14` `every('draw', ...)`
- `exs/click-drag-cancel.lua:14` `spawn(function ...)`
- `exs/click-drag-cancel.lua:16` `every('draw', ...)`
- `exs/click-drag-cancel.lua:38` `every('mouse.motion', ...)`
- no `task()` accessor

Mechanical migration:
- `every(`            -> `loop_on(`
- `spawn(function...` -> `do_spawn(function...` (self-contained)
                      else `spawn(task(function...))`

Rocks branch-track `v0.3`, so pushing the fix to `v0.3` already
serves it under `0.3-1`; a new rock rev `0.3-2` (+ `dev-3`,
replaces `dev-2`) is only to re-publish. Mirror atmos `0.7-2`.

## Steps (this re-cut)

1. [x] Migrate the 5 sites above (loop_on x3, do_spawn x1)
2. [x] Grep clean: no `every(` / `task()` / bare `spawn(`

3. [ ] Test local (LUA_PATH trick, no install of env-pico):
   run each from worktree root, point LUA_PATH at `./?.lua`
   so `atmos.env.pico` resolves to the edited source:
   - `LUA_PATH="./?.lua;./?/init.lua;;" lua5.4 exs/hello.lua`
   - `... lua5.4 exs/across.lua`
   - `... lua5.4 exs/click-drag-cancel.lua`
   PASS = no `loop_on`/`do_spawn` nil errors; windows behave.

4. [~] WON'T DO -- Rockspec rev `0.3-2` + `dev-3`.
   Verified (2026-06-19): `0.3-1` content already correct for
   0.7-2 -- `atmos ~> 0.7` matches `0.7-2` (>=0.7,<0.8),
   `pico-sdl ~> 0.6`, `branch=v0.3`, modules all unchanged.
   Branch-tracking means pushing the migration to `v0.3` serves
   it under `0.3-1`; a `0.3-2` rev would be pure republish
   bookkeeping. Keep `0.3-1` + `dev-2` as-is.

5. [ ] Install global + test:
   - `sudo luarocks make atmos-env-pico-0.3-1.rockspec`
   - rerun the 3 exs WITHOUT the LUA_PATH trick (uses rock)

6. [ ] Commit + push:
   - branch `v0.3`: commit migration + rockspec
   - push `v0.3`; fast-forward `main` to it; push `main`
   - (NEVER auto-commit/push -- ASK Francisco first)

7. [~] Publish -- N/A (no rev). `0.3-1` already published &
   resolving against atmos `0.7-2`. Nothing to upload unless a
   `0.3-2` rev is later decided.

8. [x] Downstream apps (see section below): both migrated to
   atmos 0.7-2, RUN OK, committed, merged to `main`, pushed.

## Downstream apps (no own plan -- handle here)

CORRECTION (2026-06-19): prior-cut §8 claimed these apps were
"migrated + TESTED OK". FALSE -- the committed `v0.6` code was
still FULL pre-0.7 idiom (`every('clock')`, bare `spawn`,
`task()`). Only `birds-11` had a partial 0.7-1 touch (dc562af).
So this was a FULL atmos-0.7-2 migration, not mechanical renames.

REFERENCE = the fully-migrated SDL twins `../sdl-birds` /
`../sdl-rocks` (each pico file maps 1:1 to its sdl twin's
control-flow; only rendering API differs).

4 rules (validated vs twins + `../atmos/atmos/init.lua`):
- R1 `every(`            -> `loop_on(`
- R2 `task().x` (me)     -> `xtask().x`
- R3 spawned named body  -> wrap def in `task(...)`
     (`spawn(rawFn)` now errors "expected task prototype")
- R4 `spawn(function..)` anon -> `do_spawn(function..)`
Already-0.7 (UNCHANGED): `us` clock, `_ms_`/`_s_`, table
`key.dn`/`Show`, watching/par/toggle/catch/throw/emit_in,
`await(N)`, `await(spawn(..))`.

- [x] `../pico-birds` (branch `v0.6`): ALL `birds-01..11.lua`
      migrated (R1+R3 all; R2 in 07-11), `luac -p` clean,
      RUN OK. Committed, merged to `main`, pushed both.
- [x] `../pico-rocks` (branch `v0.6`): `main.lua`,`ts.lua`,
      `battle.lua` migrated, `luac -p` clean, RUN OK.
      Committed, merged to `main`, pushed both.
      - main.lua: loop_on x4, do_spawn x4 (anon); `spawn(Battle)` stays
      - ts.lua: loop_on x10, xtask x7, wrap Move_T/Meteor/Shot/Ship,
        do_spawn x1 (L131 anon)
      - battle.lua: loop_on x1, wrap `Battle`

--------------------------------------------------------------

## PRIOR CUT (frozen -- atmos 0.7-1 era, for reference)

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

- [x] Create branch `v0.3` from current `main`/`v0.2` work
      (done in step 7)

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

- [x] `exs/hello.lua`
- [x] `exs/across.lua`
- [x] `exs/click-drag-cancel.lua`

### 3. README.md

- [x] Rewrote Events section to v0.7 idiom (bare clock,
      table-pattern awaits, `until` filter) mirroring env-sdl
- [x] Version refs already correct (`v0.3`, `atmos v0.7`,
      `pico-sdl v0.6`); install line has no pin (ok)

### 4. Rockspec

Create NEW `atmos-env-pico-0.3-1.rockspec` (copy `0.2-1`):

| field | v0.2 (released) | v0.3 |
|-------|-----------------|------|
| `version` | `0.2-1` | `0.3-1` |
| `source.branch` | `v0.2` | `v0.3` |
| `dependencies` atmos | `atmos >= 0.6` | `atmos ~> 0.7` |
| `pico-sdl` | `>= 0.5` | keep (verify required version) |

- [x] Create `atmos-env-pico-0.3-1.rockspec`
      (`atmos ~> 0.7`, `pico-sdl ~> 0.6`)
- [x] Verify module list (init + 3 exs)
- [x] `dev` follow: revert `dev-1`, create `dev-2`
      (`atmos ~> 0.7`, `pico-sdl ~> 0.6`, `branch = main`)

- [x] Moved OLD rockspecs to `old/` (`0.2-1`, `dev-1`);
      root now holds only `0.3-1` + `dev-2` (matches atmos layout)

### 5. Phase 1 tests (local, `LUA_PATH` trick)

- [x] `exs/hello.lua`
- [x] `exs/across.lua`
- [x] `exs/click-drag-cancel.lua`

### 6. Phase 2 tests (global, `luarocks make`)

- [x] `sudo luarocks make atmos-env-pico-0.3-1.rockspec`
- [x] `exs/hello.lua`
- [x] `exs/across.lua`
- [x] `exs/click-drag-cancel.lua`

### 7. Commit, push, branch

- [x] Commit, push `main`
- [x] Create/update branch `v0.3`, push

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
- [x] `pico-birds` ALL `birds-01..11.lua` migrated + TESTED OK
      (clock us->ms, time consts, collision `function ()`,
      `key.dn`/`Show` table emits/awaits in -11)
      NOTE: apps have NO rockspec -> dep bump N/A
- [x] `pico-rocks` (`main.lua`, `battle.lua`, `ts.lua`)
      + TESTED OK
      clock us->ms, time consts, `key.dn` table awaits,
      task-pool await `{tag='tasks',mode='any',tasks=ships}`
      + `Ship` returns `task().tag` (winner via `s=='L'`)

### 9. Publish to luarocks.org

Ecosystem status (verified via `luarocks search --all`):

| package          | local | published | ok |
|------------------|-------|-----------|----|
| atmos            | 0.7-1 | 0.7-1     | yes |
| atmos-env-sdl    | 0.2-1 | 0.2-1     | yes |
| atmos-env-pico   | 0.3-1 | 0.3-1     | yes |
| atmos-env-iup    | 0.1-1 | 0.1-1     | yes |
| atmos-env-socket | 0.1-1 | 0.1-1     | yes |
| f-streams        | 0.2-4 | 0.2-4     | yes |
| pico-sdl         | (dep) | 0.6-1     | yes |

- [x] `atmos-env-pico-0.3-1` uploaded
- [x] `atmos 0.7-1` uploaded -> dep chain now resolves
      (atmos ~> 0.7 ok, pico-sdl ~> 0.6 ok)

- [x] `luarocks install atmos-env-pico` -> installs `0.3-1`
      (clean-room: removed shadowing `dev-2`, reinstalled);
      installed rock = `0.3-1`, module loads OK. VERIFIED.
- [x] `atmos-env-sdl 0.2-1` published (verified)

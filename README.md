# zim-jj-waltz

> [Zim](https://zimfw.sh/) module that initializes [`jw`](https://github.com/rektide/jj-waltz) — the jj-waltz workspace switcher — with a cached, precompiled wrapper plus dynamic completions.

## What it does

Three things, in one module:

1. **Cached wrapper** — `jw shell init zsh` (the cd-enabling `jw()` function: bare `jw`/`jw ui` enter the picked workspace, `s`/`switch`/`^`/`-` cd to the target) is generated once, written to a cache file with the trailing completions eval stripped, `zcompile`d into a `.zwc`, and sourced. Shell startup skips re-running and re-parsing the generated script.
2. **Smart regeneration** — the cache rebuilds only when the `jw` binary is newer than the cache (e.g. after `cargo install`). Mirrors the mtime idiom from [`rektide/zim-jujutsu`](https://github.com/rektide/zim-jujutsu) and [`rektide/zim-zoxide`](https://github.com/rektide/zim-zoxide).
3. **Completions** — `jw <TAB>` completes subcommands and options through jw's own Clap dynamic completer, regenerated into [`functions/_jw`](functions/) when the binary updates. Zim puts a module's `functions/` on `fpath`, and `compinit` autoloads the `#compdef jw` script — no per-shell `eval`.

## Install

In `~/.zimrc` (or your zimrc drop-in):

```zsh
zmodule rektide/zim-jj-waltz
```

Then:

```zsh
zimfw install
```

Load order: place it **before** Zim's `completion` module so `functions/_jw` is on `fpath` when `compinit` runs (the standard tools-before-completion ordering).

## Usage

Nothing to call — the wrapper and completions are wired up on load:

```zsh
jw s my-feature   # switch: cd into the workspace (prints path with -x)
jw                # no args: pick via the UI, then cd
jw add worker-a   # everything else passes straight through
jw reseed <TAB>   # dynamic completion from the live binary
```

## How it works

[`init.zsh`](init.zsh) runs, in order:

1. Exits early if `jw` is not in `$PATH`.
2. Regenerates `functions/_jw` from `command jw shell completions zsh` when missing or older than the binary.
3. Caches `command jw shell init zsh` to `.jw-init.zsh` with the final `eval "$(command jw shell completions zsh)"` line filtered out — completions are already on `fpath`, and `compdef` does not exist yet at module-load time — then `zcompile`s and sources it.

## Notes

- The `jw` binary itself is installed separately (`cargo install --path . --locked` from a jj-waltz checkout). This module only wires the shell side and follows binary upgrades via mtime.
- The `.jw-init.zsh` cache, `functions/_jw`, and `*.zwc` artifacts are gitignored and live in the module directory at runtime.
- The completions delegate to the live `jw` binary at completion time (`_JW_COMPLETE=zsh`), so they never go stale within a binary version.

## License

MIT

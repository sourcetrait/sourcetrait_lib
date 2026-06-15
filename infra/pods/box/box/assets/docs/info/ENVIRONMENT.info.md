# ENVIRONMENT.md

This environment is ran within a Podman container.

The container image is `sourcetrait/box`, layered over `fedora-toolbox`.

The operating system is `fedora` Linux.

The shell is `nushell`.

The user is `box`.

The user home is `/home/box`.

The environment EDITOR is `helix`.

The following tools / packages are explicitly available:
- `nodejs` and `npm`
- `rustup`, `cargo`, `rustc`, `ast-grep`, `cargo-cache`, `rust-src`, `cargo-expand`, `rust-analyzer`, `+nightly` 
- `nushell`
- `python3-lxml`
- `ripgrep`, `tokei`, `fd-find`, `tree-sitter-cli`, `tree-sitter`, `libtree-sitter`, `libtree-sitter-rust`
- `jq`, `git-lfs`, `yazi`

All of the tools available to a `fedora-toolbox` container image are available.

The following tools / packages are known to be implicitly available:
- `python3` (aliased to `python`)

The user's home directory is non-standard:
- `~/ai`: Harnesses for AI agents
- `~/data`: Data files, dumps, etc.
- `~/info`: Documentation, notes, etc.
- `~/misc`: Files that don't fit anywhere else
- `~/proj`: Projects and project repositories
- `~/repo`: Third-party repositories
- `~/sys`: User-level system configuration
  - `~/sys/app`: Installation path for first-party software not covered by another `$env.PATH`
    - `~/sys/app/bin`: Executables
    - `~/sys/app/lib`: Libraries, modules, includes, etc.
    - `~/sys/app/share`: Assets
  - `~/sys/local`: Installation path for manually installed third-party software
- `~/tmp`: User-level temporary directory

All of the user home directories listed, except for `~/sys`, are intended for
general use at the user's discretion.

The `~/sys` directory contains:
- `~/sys/.xdg/{data,cache,state}`: Non-default dirs for XDG_{DATA,CACHE,STATE}
- `~/sys/.rustup`: The `rustup` home path
- `~/sys/.cargo`: The `cargo` home path

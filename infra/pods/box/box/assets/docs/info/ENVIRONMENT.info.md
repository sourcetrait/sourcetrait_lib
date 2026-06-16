# ENVIRONMENT.md

This environment is ran within a Podman container.

The container image is `sourcetrait/box`, layered over `fedora-toolbox`.

The shell is `nushell`. The user is `box`. The user home is `/home/box`.

The environment EDITOR is `helix`.

The user's home directory is non-standard:
- `~/ai`: Harnesses for AI agents
- `~/data`: Data files, dumps, etc.
- `~/info`: Documentation, notes, etc.
- `~/misc`: Files that don't fit anywhere else
- `~/proj`: Projects and project repositories
- `~/repo`: Third-party repositories
- `~/tmp`: User-level temporary directory

Special directories:
- `~/.config` Normal software configuration
- `~/.sys`: System configuration and data
  - `~/.sys/app`: Installation path for first-party software not covered by another `$env.PATH`
  - `~/.sys/local`: Installation path for manually installed third-party software
  - `~/.sys/.xdg`
  - Dot-files for Cargo, Git, NPM, NodeJS, Pip, Python, RustUp, etc
  
All of the tools available to the `fedora-toolbox` container image are installed.

The following tools / packages are additionally available:
- `nodejs` `npm` `rustup` `cargo` `ast-grep` `cargo-cache` `rust-src`
- `cargo-expand`, `rust-analyzer` `rust +nightly` `nushell` `python3-lxml`
- `ripgrep` `tokei` `fd-find` `tree-sitter-cli` `tree-sitter` `libtree-sitter`
- `libtree-sitter-rust` `jq` `git-lfs` `yazi`

# do not use nushell's defualt banner; we have our own
$env.config.show_banner = false

# setup default env path to point at the app/bin and at cargo's bin
$env.PATH = ($env.PATH | append [
  ($env.HOME | path join 'sys/.cargo/bin')
  ($env.HOME | path join 'app/bin')
])

# enable full color support
$env.COLORTERM = "truecolor"

# defualt editor is helix
$env.EDITOR = "hx"

# xdg cache, data, state default to dirs within `~/sys/.xdg`
$env.XDG_CACHE_HOME = ($env.HOME | path join 'sys/.xdg/cache')
$env.XDG_DATA_HOME = ($env.HOME | path join 'sys/.xdg/data')
$env.XDG_STATE_HOME = ($env.HOME | path join 'sys/.xdg/state')

# setup cargo's env
$env.CARGO_HOME = ($env.HOME | path join 'sys/.cargo')

# setup rustup's env
$env.RUSTUP_HOME = ($env.HOME | path join 'sys/.rustup')

# (box feature: claude) claude's env and claude.json
$env.CLAUDE_CONFIG_DIR = ($env.HOME | path join 'sys/.claude')

# non-standard: secondary timezone, different than the system
# eg, "America/Los_Angeles"
# keeping the system timezone in UTC has its portability benefits
# used primarily for the claude status-line
$env.ALT_TZ = "UTC"
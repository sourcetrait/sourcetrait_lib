# setup default env path to point at the app/bin and at cargo's bin
$env.PATH = ($env.PATH | append [
  ($env.HOME | path join 'sys/local/bin')
  ($env.HOME | path join 'sys/.cargo/bin')
  ($env.HOME | path join 'sys/.python/bin')
  ($env.HOME | path join 'app/bin')
])

# xdg cache, data, state default to dirs within `~/sys/.xdg`
$env.XDG_CACHE_HOME = ($env.HOME | path join 'sys/.xdg/cache')
$env.XDG_DATA_HOME = ($env.HOME | path join 'sys/.xdg/data')
$env.XDG_STATE_HOME = ($env.HOME | path join 'sys/.xdg/state')

# setup cargo's env
$env.CARGO_HOME = ($env.HOME | path join 'sys/.cargo')

# setup rustup's env
$env.RUSTUP_HOME = ($env.HOME | path join 'sys/.rustup')

# setup python's env
$env.PYTHONUSERBASE = ($env.HOME | path join 'sys/.python')
$env.PYTHONHISTFILE = ($env.HOME | path join 'sys/.python_history')
$env.PYTHONPYCACHEPREFIX = ($env.XDG_CACHE_HOME | path join 'python')

# setup NPM's user env
$env.npm_config_cache = ($env.HOME | path join 'sys/.npm')
$env.npm_config_userconfig = ($env.HOME | path join 'sys/.npmrc')

# setup nodejs's env
$env.NODE_REPL_HISTORY = ($env.HOME | path join 'sys/.node-repl-history')

# do not use nushell's defualt banner; we have our own
$env.config.show_banner = false

# enable full color support
$env.COLORTERM = "truecolor"

# defualt editor is helix
$env.EDITOR = "hx"

umask rwx------

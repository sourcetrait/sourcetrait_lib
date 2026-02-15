$env.config.show_banner = false

$env.PATH = ($env.PATH | append [
  ($env.HOME | path join 'sys/.cargo/bin')
  ($env.HOME | path join 'app/bin')
])

$env.COLORTERM = "truecolor"
$env.EDITOR = "hx"

$env.XDG_CACHE_HOME = ($env.HOME | path join 'sys/.local/cache')
$env.XDG_DATA_HOME = ($env.HOME | path join 'sys/.local/share')
$env.XDG_STATE_HOME = ($env.HOME | path join 'sys/.local/state')

$env.CARGO_HOME = ($env.HOME | path join 'sys/.cargo')
$env.RUSTUP_HOME = ($env.HOME | path join 'sys/.rustup')

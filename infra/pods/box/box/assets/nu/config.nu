##
# We attempt to keep dot-files out of ~/ and place them in ~/.sys.
# For software that doesn't adhere to the XDG spec, we typically don't
# force them to; we just let them "be bad" in ~/.sys.
##

# setup default env path to point at the app/bin and at cargo's bin
$env.PATH = ($env.PATH | append [
  ($env.HOME | path join '.sys/local/bin')
  ($env.HOME | path join '.sys/.cargo/bin')
  ($env.HOME | path join '.sys/.python/bin')
  ($env.HOME | path join '.sys/app/bin')
])

$env.XDG_CONFIG_HOME = ($env.HOME | path join '.config')

# xdg cache, data, state default to dirs within `~/.sys/.xdg`
$env.XDG_CACHE_HOME = ($env.HOME | path join '.sys/.xdg/cache')
$env.XDG_DATA_HOME = ($env.HOME | path join '.sys/.xdg/data')
$env.XDG_STATE_HOME = ($env.HOME | path join '.sys/.xdg/state')

$env.XDGX_TMP_HOME = ($env.HOME | path join 'tmp')
$env.XDGX_SHM_DIR = ('/dev/shm' | path join $env.USER)

# our own concept here: mirrored out ({cache,data,home}) with gaurantees:
# - chown user:user
# - chmod go-rwx
$env.XDGX_STRICT_CONFIG_HOME = ($env.HOME | path join '.config/strict')
$env.XDGX_STRICT_CACHE_HOME = ($env.HOME | path join '.sys/.xdg/strict/cache')
$env.XDGX_STRICT_DATA_HOME = ($env.HOME | path join '.sys/.xdg/strict/data')
$env.XDGX_STRICT_STATE_HOME = ($env.HOME | path join '.sys/.xdg/strict/state')

# our own concept here: mirrored out ({cache,data,home}) with gaurantees:
# - all requirements from XDGX_STRICT
# - extended system access-control architecture is used (selinux, app armor)
$env.XDGX_SECURE_CONFIG_HOME = ($env.HOME | path join '.config/secure')
$env.XDGX_SECURE_CACHE_HOME = ($env.HOME | path join '.sys/.xdg/secure/cache')
$env.XDGX_SECURE_DATA_HOME = ($env.HOME | path join '.sys/.xdg/secure/data')
$env.XDGX_SECURE_STATE_HOME = ($env.HOME | path join '.sys/.xdg/secure/state')

# vendor defaults for the XDGX concepts: fallback in-order if the env variable
# isn't available 

# our own concept here: give modern vendors a standard place to install to at
# a user-level. EXECUTE_HOME is expected to be in the user's PATH
$env.XDGX_EXECUTE_HOME = ($env.HOME | path join '.sys/local/bin')
$env.XDGX_LIBRARY_HOME = ($env.HOME | path join '.sys/local/lib')
$env.XDGX_PACKAGE_HOME = ($env.HOME | path join '.sys/local/pkg')

# setup git's env
$env.GIT_CONFIG_GLOBAL = ($env.HOME | path join '.sys/.gitconfig')

# setup cargo's env
$env.CARGO_HOME = ($env.HOME | path join '.sys/.cargo')
$env.CARGO_TARGET_DIR = '/var/local/cache/box/cargo/target'

# setup rustup's env
$env.RUSTUP_HOME = ($env.HOME | path join '.sys/.rustup')

# setup python's env
$env.PYTHONUSERBASE = ($env.HOME | path join '.sys/.python')
$env.PYTHONHISTFILE = ($env.HOME | path join '.sys/.python_history')
$env.PYTHONPYCACHEPREFIX = ($env.XDG_CACHE_HOME | path join 'python')

# setup NPM's user env
$env.npm_config_cache = ($env.HOME | path join '.sys/.npm')
$env.npm_config_userconfig = ($env.HOME | path join '.sys/.npmrc')

# setup nodejs's env
$env.NODE_REPL_HISTORY = ($env.HOME | path join '.sys/.node-repl-history')

# do not use nushell's defualt banner; we have our own
$env.config.show_banner = false

# enable full color support
$env.COLORTERM = "truecolor"

# defualt editor is helix
$env.EDITOR = "hx"

# non-standard: secondary timezone, different than the system
# eg, "America/Los_Angeles"
# keeping the system timezone in UTC has its portability benefits
$env.ALT_TZ = "America/Los_Angeles"

umask rwx------

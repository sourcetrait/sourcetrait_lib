# claude's env and claude.json re-homed to sys
$env.CLAUDE_CONFIG_DIR = ($env.HOME | path join 'sys/.claude')

# non-standard: secondary timezone, different than the system
# eg, "America/Los_Angeles"
# keeping the system timezone in UTC has its portability benefits
$env.ALT_TZ = "UTC"



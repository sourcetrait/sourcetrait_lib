$env.box_name = 'box'

# show the banner
nu ($nu.default-config-dir | path join 'banner.nu')

# display a new-user welcome that points at the introductory documentation
# the user is expected to delete `WELCOME.md` when they are comfortable
if ($nu.home-dir | path join 'WELCOME.md' | path exists) {
    print $"\nUse (ansi yellow)glow WELCOME.md(ansi reset) to begin.\n"
}

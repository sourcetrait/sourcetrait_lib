$env.box_name = 'box'
nu ($nu.default-config-dir | path join 'banner.nu')

if ($nu.home-dir | path join 'WELCOME.md' | path exists) {
  print $"\nUse (ansi yellow)glow WELCOME.md(ansi reset) to begin.\n"
}

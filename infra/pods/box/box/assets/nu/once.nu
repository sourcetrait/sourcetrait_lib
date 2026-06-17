# Iterates through the .config/nushell/once directory if it exists.
# Runs each nu script then deletes it immediately after run.
# Deletes the once dir after successful run of all scripts.
# Handles errors gracefully; always exits 0. 
# On run error: Early exit with warning without deletion.

if not ($nu.default-config-dir | path join 'once' | path exists) {
    exit 0
}

for once_nu in (glob ($nu.default-config-dir)/once/*.nu) {
    try {
        nu $once_nu
    } catch {|e|
        print -e $"(ansi red)[once](ansi reset) failed to run: (ansi cyan)($once_nu)(ansi reset)"
        print $e
        exit 0
    }
    
    try {
        rm $once_nu
    } catch {|e|
        print -e $"(ansi orange)[once](ansi reset) failed to delete: (ansi cyan)($once_nu)(ansi reset)"
        print $e
    }
}

try {
    rm -rf ($nu.default-config-dir | path join 'once')
} catch {|e|
    print -e $"(ansi orange)[once](ansi reset) failed to delete: (ansi cyan)($nu.default-config-dir | path join 'once')(ansi reset)"
    print $e
}

exit 0

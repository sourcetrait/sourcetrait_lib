#!/bin/env nu
# Handles general system and user administration.
# 
# We ship code for features as well, despite the container not necessarily being
# shipped with them (base container "box" vs "empower, for example).
# 
# Privileged => Expects prompt_sudo and then calls mixed privilege commands
# Super => Expect prompt_sudo and perform sudo/su commands
# User  => Doesn't expect sudo and perform user-level commands

def secure_user_home [] {
    chown -R $"($env.USER):($env.USER)" $env.HOME
    chmod -R go-rwx $env.HOME 
    return
}

def prompt_sudo [] {
    ^sudo -v
}

def privileged_upgrade [] {
    super_upgrade
    user_upgrade
}

def super_upgrade [] {
    ^sudo dnf -y update
    super_upgrade_features
}

def super_upgrade_features [] {
    for feature in (features) {
        match $feature {
            $FEATURE_CLAUDE => super_upgrade_feature_claude
        }
    }
}

def user_upgrade [] {
    ^rustup update
}

const FEAUTURE_CLAUDE = "claude"
const ENUM_FEATURE = [ $FEAUTURE_CLAUDE ]
def enum_feature [] { $ENUM_FEATURE }

def features []: nothing -> list<string> {
    mut box_toml = open /usr/local/etc/sourcetrait/box/box.toml
    box_toml.features
}

def has_feature [feature: string@enum_feature]: nothing -> bool {
    $feature in (features)
}

def user_setup_claude [] {
    # claude's env and claude.json re-homed to sys
    $env.CLAUDE_CONFIG_DIR = ($env.HOME | path join 'sys/.claude')
    
    mkdir ~/ai/tmp
    cd ~/ai/tmp

    ^claude -v
    
    mkdir ~/sys/.claude/scripts
    mv /tmp/init/user/claude/CLAUDE.md ~/sys/.claude/
    mv /tmp/init/user/claude/settings.json ~/sys/.claude/

    # env vars, including CLAUDE_CONFIG_DIR
    cp /usr/local/share/box/features/claude/nu/config.claude.nu ($env.HOME | path join '.config/nushell/autoload')
    
    cd
    rm -rf ~/ai/tmp
}

# Performs all admin and user upgrades / updates / refreshes
def "main upgrade" [] {
    prompt_sudo
    priveleged_upgrade
    secure_user_home
}

# Safely prunes older user cache and temp files
def "main clean home tidy" [] {
    ^systemd-tmpfiles --clean
    clean_home_rust_unref_cache
    secure_home
}

# Wipes user temp files and cache.
def "main clean home wipe" [] {
    ^systemd-tempfiles --remove --create
    clean_home_rust
    ^cargo cache -a
    secure_home
}

# Purges user temp files and cache. Destructive.
def "main clean home purge" [] {
    ^systemd-tempfiles --purge --create
    clean_home_rust
    ^cargo cache -e
    secure_home
}

# Safely prunes all older cache and temp files, system-wide. Pair with `clean home tidy` per user.
def "main clean system tidy" [] {
    prompt_sudo
    ^systemd-tmpfiles --clean
    secure_home
}

# Wipes all temp files and cache system-wide. Destructive. Pair with `clean home wipe` per user.
def "main clean system wipe" [] {
    prompt_sudo
    ^systemd-tmpfiles --remove --create
    secure_home
}

# Purges all temp files and cache system-wide. Destructive. Pair with `clean home purge` per user.
def "main clean system purge" [] {
    prompt_sudo
    ^systemd-tmpfiles --purge --create
    secure_home
}

def clean_home_rust [] {
    clean_all_rust ($env.HOME | path join './proj')
    clean_all_rust ($env.HOME | path join './repo')
}

def clean_home_rust_unref_cache [] {
    clean_all_rust_unref_cache ($env.HOME | path join './proj')
    clean_all_rust_unref_cache ($env.HOME | path join './repo')
}

# Perform `cargo clean` of Rust projects
# 
# Searches for Cargo projects and attempts to clean each.
def clean_all_rust [
    search_dir: path # the directory to recursively search for projects in
] {
    let cargo_dirs = find_cargo_dirs $search_dir
    
    print $"(ansi grey)[boxing](ansi reset) cleaning in: (ansi cyan)($search_dir)(ansi reset)"
    
    if ($cargo_dirs.unlinked | is-empty) {
        print $"(ansi yellow)[boxing](ansi reset) skipped unlinked: (ansi cyan)($cargo_dirs.unlinked)(ansi reset)"
    }
    
    for project_dir in $cargo_dirs.found {
        let search_project_dir = $project_dir | path relative-to $search_dir
        
        print $"(ansi grey)[boxing](ansi reset) cleaning: (ansi cyan)($search_project_dir)(ansi reset)"
    
        cd $project_dir
        let rslt = (^cargo clean | complete)
        if $rslt.exit_code != 0 {
            print $"(ansi yellow)[boxing](ansi reset) cargo clean failed. cleaning manually ..."
            let target_dir = $project_dir | path join "target" | path expand
            if ($target_dir | path exists) {
                rm --recursive --force $target_dir
                print $"$(ansi green)[boxing](ansi reset) deleted: ($target_dir)"
            }
        }
    }
}

# Perform `cargo clean-unref` of Rust projects
# 
# Searches for Cargo projects and attempts to clean cache for each.
def clean_all_rust_unref_cache [
    search_dir: path # the directory to recursively search for projects in
] {
    let cargo_dirs = find_cargo_dirs $search_dir
    
    print $"(ansi grey)[boxing](ansi reset) cleaning in: (ansi cyan)($search_dir)(ansi reset)"
    
    if ($cargo_dirs.unlinked | is-empty) {
        print $"(ansi yellow)[boxing](ansi reset) skipped unlinked: (ansi cyan)($cargo_dirs.unlinked)(ansi reset)"
    }
    
    for project_dir in $cargo_dirs.found {
        let search_project_dir = $project_dir | path relative-to $search_dir
        
        print $"(ansi grey)[boxing](ansi reset) cleaning: (ansi cyan)($search_project_dir)(ansi reset)"
    
        cd $project_dir
        let rslt = (^cargo clean-unref | complete)
        if $rslt.exit_code != 0 {
            print $"(ansi yellow)[boxing](ansi reset) cargo cache clean-unref failed"
        }
    }
}

def find_cargo_dirs [search_dir: path]: nothing -> record<found: list<path>, unlinked: list<path>> {
    let search_dir = $search_dir | path expand
    if not ($search_dir | path exists) {
        error make { msg: $"directory does not exist: ($search_dir)" }
    }
    
    mut found: list<path> = []
    mut unlinked: list<path> = []
    
    let cargo_toml_files = glob $"($search_dir)/**/Cargo.toml"
    for cargo_toml_file in $cargo_toml_files {
        let project_dir = ($cargo_toml_file | path dirname)
        let project_dir_rel = $project_dir | path relative-to $search_dir
        
        if not ($project_dir | path exists) {
            $unlinked = $unlinked | append $project_dir
        } else {
            $found = $found | append $project_dir
        }
    }

    {
        found: $found,
        unlinked: $unlinked
    }
}

# Performs administrative taks on Box containers
def "main" [] { help }

def super_upgrade_feature_claude [] {
    ^sudo npm install -g @anthropic-ai/claude-code
}
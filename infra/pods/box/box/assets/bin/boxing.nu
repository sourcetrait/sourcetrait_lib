#!/bin/env nu

def "main upgrade" [] {
    upgrade
    user_secure_home
}

def upgrade [] {
    super_upgrade
    user_upgrade
}

def super_upgrade [] {
    ^sudo dnf -y update
}

def user_upgrade [] {
    ^rustup update
}

def "main install claude" [] {
    mut features_toml = open /usr/local/etc/box/features.toml
    if "claude" in $features_toml.features {
        print "feature already installed: claude"
        return
    }
    
    upgrade
    super_install_claude
    user_setup_claude

    $features_toml.features = ($features_toml.features | append "claude")
    $features_toml | save /usr/local/etc/features.toml
    
    user_secure_home 
}

def super_install_claude [] {
    ^npm install -g @anthropic-ai/claude-code
}

def user_setup_claude [] {
    # claude's env and claude.json re-homed to sys
    $env.CLAUDE_CONFIG_DIR = ($env.HOME | path join 'sys/.claude')
    
    mkdir ~/ai/tmp
    cd ~/ai/tmp

    ^claude -v
    # trigger creation of initial config
    ^claude -p "exit" e>| ignore
    
    mkdir ~/sys/.claude/scripts
    mv /tmp/init/user/claude/CLAUDE.md ~/sys/.claude/
    mv /tmp/init/user/claude/settings.json ~/sys/.claude/
    mv /tmp/init/user/claude/statusline.bash ~/sys/.claude/scripts/

    # env vars, including CLAUDE_CONFIG_DIR
    cp /usr/local/share/box/features/claude/nu/config.claude.nu ($env.HOME | path join '.config/nushell/autoload')
    
    cd
    rm -rf ~/ai/tmp
}

def user_secure_home [] {
    chown -R $"($env.USER):($env.USER)" $env.HOME
    chmod -R go-rwx $env.HOME 
    return
}
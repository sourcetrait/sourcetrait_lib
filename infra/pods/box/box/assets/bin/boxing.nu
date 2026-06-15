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

# Performs administrative taks on Box containers
def "main" [] { help }

def super_upgrade_feature_claude [] {
    ^sudo npm install -g @anthropic-ai/claude-code
}
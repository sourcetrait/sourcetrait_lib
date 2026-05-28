#!/bin/env nu

def feature_claude [] {
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
    
    cd
    rm -rf ~/ai/tmp
}
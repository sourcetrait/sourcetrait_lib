#!/bin/env nu

def feature_claude [] {
    mkdir ~/ai/tmp
    cd ~/ai/tmp
    
    ^claude -v
    ^claude -p "exit" e>| ignore
    
    mv /tmp/init/user/claude/CLAUDE.md .claude/
    mv /tmp/init/user/claude/settings.json .claude/
    
    rm -rf ~/ai/tmp
}
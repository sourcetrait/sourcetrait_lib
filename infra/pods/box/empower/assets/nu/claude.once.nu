#!/bin/env nu

def main [] {
    let claude_json_file = ($env.CLAUDE_CONFIG_DIR | path join '.claude.json')
    
    claude mcp add --scope user --transport stdio nushell /usr/local/bin/sourcetrait/empower/nushell_mcp
    
    open $claude_json_file
        | update mcpServers.nushell.alwaysLoad true
        | save -f $claude_json_file
}
module boxshell {
    # Simply list files ordered by type first
    export def l []: nothing -> table { %ls | sort-by type name }
}
#!/bin/bash

function zbash() {
    # ZBash configuration files with command implementation.
    local help="
zbash collection of command scripts

USAGE: zbash [sub_command] [... args]
COMMANDS:
$ZBASH_SCRIPTS_SUBMENU_COMMANDS_HELP

FLAGS:
    -h | --help     Show this help menu.
"
    local function_name=""
    local dump=""
    local command="$1"
    shift

    [ -n "$command" ]
    assert $? "Please provide a command to execute, or --help for help" || return $?

    case "$command" in
    --help | -h)
        echo "$help"
        return 0
        ;;
    *)
        zbash_load_submenu_scripts
        assert $? "Failed to load submenu scripts" || return $?
        function_name="__zbash_script_$command"
        dump="$(type -t "$function_name" 2>&1)"
        assert $? "Command not found $command" || return $?
        ;;
    esac

    "$function_name" "$@"
}

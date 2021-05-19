#!/bin/bash
# Color format should use string internal color format.
# i.e.: "\[\e[30;1m\]"
if [ "$ZBASH_CONFIG_NO_COLORS" != "true" ]; then
    ZBASH_CONFIG_COLOR_HOSTNAME="\[\e[38;5;237m\]"
    ZBASH_CONFIG_COLOR_CLOCK="\[\e[34;1m\]"
    ZBASH_CONFIG_COLOR_VENV="\[\e[38;5;177m\]"
    ZBASH_CONFIG_COLOR_USER="\[\e[91;1m\]"
    ZBASH_CONFIG_COLOR_PATH="\[\e[36;1m\]"
    ZBASH_CONFIG_COLOR_GIT_BRANCH="\[\e[32;1m\]"
    ZBASH_CONFIG_COLOR_STATUS_INFO="\[\e[36;1m\]"
    ZBASH_CONFIG_COLOR_STATUS_ERROR="\[\e[31;1m\]"
    ZBASH_CONFIG_COLOR_COMMAND_LINE="\[\e[0;0m\]"
    ZBASH_CONFIG_COLOR_GIT_STATUS_EMPTY="\[\e[32;1m\]"
    ZBASH_CONFIG_COLOR_GIT_STATUS_PENDING="\[\e[91;1m\]"
fi

function zbash_config_colorzie() {
    local color="$1"
    shift
    local print_line="$(echo "$@")"
    echo "$color$print_line""\[\e[0m\]"
}

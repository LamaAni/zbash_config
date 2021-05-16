#!/bin/bash
if [ "$ZBASH_CONFIG_NO_COLORS" != "true" ]; then
    export ZBASH_CONFIG_COLOR_HOSTNAME=$'\e[38;5;237m'
    export ZBASH_CONFIG_COLOR_CLOCK=$'\e[34;1m'
    export ZBASH_CONFIG_COLOR_VENV=$'\e[38;5;177m'
    export ZBASH_CONFIG_COLOR_USER=$'\e[91;1m'
    export ZBASH_CONFIG_COLOR_PATH=$'\e[36;1m'
    export ZBASH_CONFIG_COLOR_GIT_BRANCH=$'\e[32;1m'
    export ZBASH_CONFIG_COLOR_STATUS_INFO=$'\e[36;1m'
    export ZBASH_CONFIG_COLOR_STATUS_ERROR=$'\e[31;1m'
    export ZBASH_CONFIG_COLOR_COMMAND_LINE=$'\e[0;0m'
    export ZBASH_CONFIG_COLOR_GIT_STATUS_EMPTY=$'\e[32;0m'
    export ZBASH_CONFIG_COLOR_GIT_STATUS_PENDING=$'\e[91;0m'
fi

function zbash_config_colorzie() {
    local color="$1"
    shift
    printf "%s" "$color"
    printf "%s" "$@"
    printf "%s" $'\e[0m'
}

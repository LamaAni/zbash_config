#!/usr/bin/env bash
SCRIPT_PATH=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
source "$SCRIPT_PATH/common.sh"


function create_show_param() {
    local do_show="$1"
    local what="$2"
    local prefex="$3"

    if [ "$do_show" == "true" ] && [ "$(trim_str $what)" != "" ]; then
        printf "%s" "$prefex$what"
    else
        printf ""
    fi
}

: ${ZLIB_BASH_SHOW_GIT:="true"}
: ${ZLIB_BASH_SHOW_PATH:="true"}
: ${ZLIB_BASH_SHOW_USER:="true"}
: ${ZLIB_BASH_SHOW_CLOCK:="true"}
: ${ZLIB_BASH_SHOW_VENV:="true"}

: ${ZLIB_BASH_SHOW_HOST:="false"}

: ${Z_BASH_PROMPT:=""}

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
: ${THEME_CLOCK_COLOR:=""}
: ${THEME_CLOCK_FORMAT:="%H:%M"}

export CLICOLOR=1

function prompt_command() {
    # This needs to be first to save last command return code
    local RC="$?"

    local very_gray="\e[38;5;237m"
    local virtual_env_color="\e[38;5;177m"

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${bold_cyan}"
    else
        ret_status="${bold_red}"
    fi

    # Append new history lines to history file
    history -a

    local print_clock="$(create_show_param $ZLIB_BASH_SHOW_CLOCK "$(date +"$THEME_CLOCK_FORMAT")" "${bold_blue}")"
    local path_print="$(create_show_param $ZLIB_BASH_SHOW_PATH "${PWD}" "${bold_cyan}")"
    local hostname_print="$(create_show_param $ZLIB_BASH_SHOW_HOST "\h" "${very_gray}")"
    local user_print="$(create_show_param $ZLIB_BASH_SHOW_USER "\u" "${bold_orange}")"
    local print_git="$(create_show_param $ZLIB_BASH_SHOW_GIT "$(git_prompt)" "${bold_green}")"
    local print_venv="$(create_show_param $ZLIB_BASH_SHOW_VENV "$(virtualenv_prompt)" "${virtual_env_color}")"

    local print_args=(
        "$print_clock"
        "$print_venv"
        "$print_git"
        "$core_print"
        "$path_print"
        "$user_print"
        "$hostname_print"
    )

    local clean_args=()
    for p in "${print_args[@]}"; do
        p="$(trim_str "$p")"
        if [ "$p" == "" ]; then
            continue
        fi
        clean_args+=("$p${reset_color}")
    done

    local header_line="$(jon_str " " "${clean_args[@]}")"

    # original
    # PS1="$(clock_prompt)${virtualenv}${hostname} ${bold_cyan}\W $(scm_prompt_char_info)${ret_status}→ ${normal}"
    PS1="$header_line"$'\n'"${Z_BASH_PROMPT}${ret_status}> ${normal}"
}

safe_append_prompt_command prompt_command

#!/usr/bin/env bash

command -v git.exe &>/dev/null
if [ $? -eq 0 ]; then
    ZLIB_BASH_HAS_GIT_EXE=1
fi

function git_use_exec() {
    if [ $ZLIB_BASH_HAS_GIT_EXE -eq 1 ]; then
        case "$PWD" in
        /mnt/?/*)
            echo "true"
            return 0
            ;;
        esac
    fi
    echo "false"
    return 1
}

function git_command_with_wsl() {
    if [ "$(git_use_exec)" == "true" ]; then
        git.exe "$@" || return $?
    else
        git "$@" || return $?
    fi
}

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch() {
    local unsafe_ref
    unsafe_ref="$(git_command_with_wsl symbolic-ref -q HEAD 2>/dev/null)" || return $?
    local stripped_ref=${unsafe_ref##refs/heads/}
    local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
    echo $clean_ref
}

function git_prompt() {
    local ref
    local is_git_repo=1
    local status
    local git_status_flags=('--porcelain')
    ref="$(git_clean_branch)" || is_git_repo=0
    if [ $is_git_repo -eq 1 ]; then
        status=$(git_command_with_wsl status ${git_status_flags} 2>/dev/null | tail -n1)

        if [ -n "$status" ]; then
            status="$SCM_THEME_PROMPT_DIRTY"
        else
            status="$SCM_THEME_PROMPT_CLEAN"
        fi

        echo -e "${SCM_THEME_PROMPT_PREFIX}${ref}${status}${SCM_THEME_PROMPT_SUFFIX}"
    fi
}

function check_show(){
    local do_show="$1"
    local what="$2"
    if [ "$do_show" == "true" ]; then
        echo "$what"
    else
        echo ""
    fi
}

: ${ZLIB_BASH_SHOW_CORE:="true"}
: ${ZLIB_BASH_SHOW_PATH:="true"}
: ${ZLIB_BASH_SHOW_HOST:="false"}
: ${ZLIB_BASH_SHOW_USER:="true"}
: ${Z_BASH_PROMPT:=""}

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"    
SCM_THEME_PROMPT_PREFIX=" ${bold_green}"
SCM_THEME_PROMPT_SUFFIX=" "
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$bold_blue"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M"}

function prompt_command() {
    # This needs to be first to save last command return code
    local RC="$?"

    local very_gray="\e[38;5;237m"
    local virtual_env_color="\e[38;5;177m"
    hostname="\u@\h"
    virtualenv="$(virtualenv_prompt)"

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${bold_green}"
    else
        ret_status="${bold_red}"
    fi

    # Append new history lines to history file
    history -a

    local core_print=$(check_show $ZLIB_BASH_SHOW_CORE "$(clock_prompt)${reset_color}${reset_color}${virtual_env_color}${virtualenv}${reset_color}$(git_prompt)${ret_status}${bold_cyan}")
    local path_print=$(check_show $ZLIB_BASH_SHOW_PATH "${PWD}")
    local hostname_print=$(check_show $ZLIB_BASH_SHOW_HOST " ${very_gray}${hostname}")
    local user_print=$(check_show $ZLIB_BASH_SHOW_USER " ${bold_orange}\u")

    # original
    # PS1="$(clock_prompt)${virtualenv}${hostname} ${bold_cyan}\W $(scm_prompt_char_info)${ret_status}→ ${normal}"
    PS1="${core_print}${path_print}${user_print}${hostname_print}"$'\n'"${Z_BASH_PROMPT}${bold_cyan}> ${normal}"
}

safe_append_prompt_command prompt_command

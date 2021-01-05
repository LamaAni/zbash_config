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

function trim_str() {
    echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

function jon_str() {
    local with="$1"
    shift
    local arr=("$@")
    local jon_stred=""
    local is_first=1
    for v in "${arr[@]}"; do
        if [ $is_first -ne 1 ]; then
            jon_stred="$jon_stred$with"
        fi
        is_first=0
        jon_stred="$jon_stred$v"
    done
    echo "$jon_stred"
}

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch() {
    local unsafe_ref
    unsafe_ref="$(git_command_with_wsl symbolic-ref -q HEAD 2>/dev/null)" || return $?
    local stripped_ref=${unsafe_ref##refs/heads/}
    local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
    echo "$clean_ref"
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

function create_show_param() {
    local do_show="$1"
    local what="$2"
    local prefex="$3"

    if [ "$do_show" == "true" ] && [ "$(trim_str $what)" != "" ]; then
        echo "$prefex$what"
    else
        echo ""
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
    local virtualenv="$(virtualenv_prompt)"

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${bold_cyan}"
    else
        ret_status="${bold_red}"
    fi

    # Append new history lines to history file
    history -a

    local print_clock=$(create_show_param $ZLIB_BASH_SHOW_CLOCK "$(date +"$THEME_CLOCK_FORMAT")" "${bold_blue}")
    local print_venv=$(create_show_param $ZLIB_BASH_SHOW_VENV "${virtualenv}" "${virtual_env_color}")
    local print_git=$(create_show_param $ZLIB_BASH_SHOW_GIT "$(git_prompt)" "${bold_green}")
    local path_print=$(create_show_param $ZLIB_BASH_SHOW_PATH "${PWD}" "${bold_cyan}")
    local hostname_print=$(create_show_param $ZLIB_BASH_SHOW_HOST "\h" "${very_gray}")
    local user_print=$(create_show_param $ZLIB_BASH_SHOW_USER "\u" "${bold_orange}")

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

    local header_line=$(jon_str " " "${clean_args[@]}")

    # original
    # PS1="$(clock_prompt)${virtualenv}${hostname} ${bold_cyan}\W $(scm_prompt_char_info)${ret_status}→ ${normal}"
    PS1="$header_line"$'\n'"${Z_BASH_PROMPT}${ret_status}> ${normal}"
}

safe_append_prompt_command prompt_command

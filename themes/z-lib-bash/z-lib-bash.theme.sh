#!/usr/bin/env bash

type git.exe >>/dev/null
if [ $? -eq 0 ]; then
    ZLIB_BASH_HAS_GIT_EXE=1
fi

function git_use_exec() {
    local USE_LIN_GIT=1
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
        exec git.exe "$@"
    else
        exec git "$@"
    fi
}

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch() {
    local unsafe_ref=$(git_command_with_wsl symbolic-ref -q HEAD 2>/dev/null)
    local stripped_ref=${unsafe_ref##refs/heads/}
    local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
    echo $clean_ref
}

function git_propmpt() {
    local ref
    local status
    local git_status_flags=('--porcelain')
    SCM_STATE=${SCM_THEME_PROMPT_CLEAN}

    if [[ "$(git_command_with_wsl config --get bash-it.hide-status)" != "1" ]]; then
        # Get the branch reference
        ref=$(git_clean_branch) ||
            ref=$(git_command_with_wsl rev-parse --short HEAD 2>/dev/null) || return 0
        SCM_BRANCH=${SCM_THEME_BRANCH_PREFIX}${ref}

        # Get the status
        [[ "${SCM_GIT_IGNORE_UNTRACKED}" == "true" ]] && git_status_flags+='-untracked-files=no'
        status=$(git_command_with_wsl status ${git_status_flags} 2>/dev/null | tail -n1)

        if [[ -n ${status} ]]; then
            SCM_DIRTY=1
            SCM_STATE=${SCM_THEME_PROMPT_DIRTY}
        fi

        # Output the git prompt
        SCM_PREFIX=${SCM_THEME_PROMPT_PREFIX}
        SCM_SUFFIX=${SCM_THEME_PROMPT_SUFFIX}
        echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
    fi
}

SCM_NONE_CHAR=''
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_THEME_PROMPT_PREFIX=" ${bold_green}"
SCM_THEME_PROMPT_SUFFIX=" "
SCM_GIT_SHOW_MINIMAL_INFO=true

CLOCK_THEME_PROMPT_PREFIX=''
CLOCK_THEME_PROMPT_SUFFIX=' '
THEME_SHOW_CLOCK=true
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$bold_blue"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M"}

VIRTUALENV_THEME_PROMPT_PREFIX='('
VIRTUALENV_THEME_PROMPT_SUFFIX=') '

: ${Z_BASH_PROMPT:=""}

if [ -n "$Z_BASH_PROMPT" ]; then Z_BASH_PROMPT="$Z_BASH_PROMPT "; fi

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

    # original
    # PS1="$(clock_prompt)${virtualenv}${hostname} ${bold_cyan}\W $(scm_prompt_char_info)${ret_status}→ ${normal}"
    PS1="$(clock_prompt)${reset_color}${reset_color}${virtual_env_color}${virtualenv}${reset_color}$(git_propmpt)${ret_status}${bold_cyan} ${PWD}${very_gray} -- ${hostname}"$'\n'"${Z_BASH_PROMPT}${bold_cyan}> ${normal}"
}

safe_append_prompt_command prompt_command

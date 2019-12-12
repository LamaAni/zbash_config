#!/usr/bin/env bash

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch {
  local unsafe_ref=$(command git symbolic-ref -q HEAD 2> /dev/null)
  local stripped_ref=${unsafe_ref##refs/heads/}
  local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
  echo $clean_ref
}

SCM_NONE_CHAR=''
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=""
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

if [ -n "$Z_BASH_PROMPT" ]; then Z_BASH_PROMPT=" $Z_BASH_PROMPT "; fi

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
    PS1="$(clock_prompt)${Z_BASH_PROMPT}${reset_color}${virtual_env_color}${virtualenv}${reset_color}$(scm_prompt_char_info)${ret_status}${bold_cyan} ${PWD}${very_gray} -- ${hostname}"$'\n'"${bold_cyan}> ${normal}"
}

safe_append_prompt_command prompt_command

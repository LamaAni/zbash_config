#!/usr/bin/env bash

# gets the return result according to storage folder
function get_env_context_for_folder() {
  local name "$1"
  local cmd="$2"
  local last_path=""
  local last_value=""

  : ${ZLIB_INFO_FILE:="/tmp/oh-my-bash-zlib-bash-status.$(whoami).$name.info"}

  if [ -f "$ZLIB_INFO_FILE" ]; then
    source "$ZLIB_INFO_FILE"
    last_path="$OMB_ZLIB_LAST_PATH"
    last_value="$OMB_ZLIB_LAST_VALUE"
  fi

  if [ "$last_path" != "$PWD" ]; then
    last_path="$PWD"
    function cmd_func() {
      $cmd 2> /dev/null
    }
    last_value=$(cmd_func)
    if [ -f "$ZLIB_INFO_FILE" ]; then
      rm -f "$ZLIB_INFO_FILE"
    fi
    echo "
export OMB_ZLIB_LAST_PATH='$last_path'
export OMB_ZLIB_LAST_VALUE='$last_value'
         " >"$ZLIB_INFO_FILE"
  fi

  echo "$last_value"
}

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch() {
  local unsafe_ref=$(get_env_context_for_folder "git_clean_branch" "command git symbolic-ref -q HEAD")
  local stripped_ref=${unsafe_ref##refs/heads/}
  local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
  echo $clean_ref
}

# faster approach 
function scm_prompt_info() {
  # scm
  # scm_prompt_char
  # scm_prompt_info_common
  echo "lama"
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
  PS1="$(clock_prompt)${reset_color}${virtual_env_color}${virtualenv}${reset_color}$(scm_prompt_char_info)${ret_status}${bold_cyan} ${PWD}${very_gray} -- ${hostname}"$'\n'"${bold_cyan}> ${normal}"
}

safe_append_prompt_command prompt_command

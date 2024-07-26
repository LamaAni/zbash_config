#!/bin/bash

: "${ZBASH_CONFIG_COMMAND_LINE_PREFIX:=""}"
: "${ZBASH_CONFIG_COMMAND_LINE_MARKER:="> "}"
: "${ZBASH_CONFIG_SHOW_HOSTNAME:="false"}"

function zbash_config_is_internactive() {
  # If not running interactively, don't do anything
  case $- in
  *i*) echo "true" ;;
  esac
  echo "false"
}

function zbash_config_join_by() {
  : "
Join array arguments
USAGE: join_by [sep] [values..]
  "
  local sep="$1"
  shift
  local joined=""
  while [ $# -gt 1 ]; do
    if [ -z "$1" ]; then
      shift
      continue
    fi
    joined="$joined$1$sep"
    shift
  done
  joined="$joined$1"
  printf "%s" "$joined"
}

function zbash_config_create_show_param() {
  local show_type="$1"
  shift
  local what="$1"
  shift
  local prefex="$3"
  shift

  if [ -z "$what" ]; then return 0; fi

  local do_show_env="ZBASH_CONFIG_SHOW_$show_type"
  local color_env="ZBASH_CONFIG_COLOR_$show_type"

  if [ "${!do_show_env}" == "false" ]; then return 0; fi
  local color="${!color_env}"
  : "${color:=$'\e[0m'}"

  zbash_config_colorzie "$color" "$prefex$what"
}

function zbash_config_prompt_command() {
  # This needs to be first to save last command return code
  local last_line_exit_status="$?"
  local linesep="$ZBASH_CONFIG_LINE_SEPERATOR"
  local auto_append_hist="$ZBASH_CONFIG_AUTO_APPEND_HIST"
  local clock_print=""
  local path_print=""
  local hostname_print=""
  local user_print=""
  local print_venv=""
  local print_git=""
  local zbash_prompt_git_status=""
  local line_marker="$ZBASH_CONFIG_COMMAND_LINE_MARKER"

  : "${auto_append_hist:="true"}"
  : "${linesep:=$'\n'}"

  # Set return status color
  if [[ ${last_line_exit_status} == 0 ]]; then
    line_marker="${ZBASH_CONFIG_COLOR_STATUS_INFO}$line_marker"
  else
    line_marker="${ZBASH_CONFIG_COLOR_STATUS_ERROR}$line_marker"
  fi

  # Append new history lines to history file
  if [ "$auto_append_hist" == "true" ]; then
    history -a
  fi

  clock_print="$(zbash_config_create_show_param CLOCK "$(zbash_prompt_clock)")"
  path_print="$(zbash_config_create_show_param PATH "$(zbash_prompt_path)")"
  hostname_print="$(zbash_config_create_show_param HOSTNAME "\$HOSTNAME")"
  user_print="$(zbash_config_create_show_param USER "\$USER")"
  print_venv="$(zbash_config_create_show_param VENV "$(zbash_prompt_venv)")"

  # Since git is a slow command. IF not shouwn then ignore.
  if [ "$ZBASH_CONFIG_SHOW_GIT_BRANCH" != "false" ]; then
    print_git="$(zbash_config_create_show_param GIT_BRANCH "$(zbash_prompt_git)")"
  fi
  : "${ZBASH_CONFIG_SHOW_GIT_BRANCH_STATUS:="$ZBASH_CONFIG_SHOW_GIT_BRANCH"}"
  if [ "$ZBASH_CONFIG_SHOW_GIT_BRANCH_STATUS" != "false" ]; then
    zbash_prompt_git_status="$(zbash_config_create_show_param GIT_BRANCH_STATUS "$(zbash_prompt_git_status)")"
  fi

  local print_args=(
    "$clock_print"
    "$print_venv"
    "$zbash_prompt_git_status"
    "$print_git"
    "$core_print"
    "$path_print"
    "$user_print"
    "$hostname_print"
  )

  PS1="$(zbash_config_join_by ' ' "${print_args[@]}")${linesep}${ZBASH_CONFIG_COMMAND_LINE_PREFIX}${line_marker}${ZBASH_CONFIG_COLOR_COMMAND_LINE}"
}

function zbash_config_set_prompt_command() {
  local cmnd_to_run="$1"
  : "${cmnd_to_run:="zbash_config_prompt_command"}"
  PROMPT_COMMAND="$cmnd_to_run"
}

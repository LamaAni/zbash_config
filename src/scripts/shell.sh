#!/bin/bash

: "${ZBASH_CONFIG_COMMAND_LINE_PREFIX:=""}"
: "${ZBASH_CONFIG_COMMAND_LINE_MARKER:="> "}"

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
      continue; 
    fi
    joined="$joined$1$sep"
    shift
  done
  joined="$joined$1"
  printf "%s" "$joined"
}

function colorize() {
  local color="$1"
  shift
  printf "%s" "$color"
  printf "%s" "$@"
  printf "%s" $'\e[0m'
}

function create_show_param() {
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

  colorize "$color" "$prefex$what"
}

function prompt_command() {
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

  clock_print="$(create_show_param CLOCK "$(prompt_clock)")"
  path_print="$(create_show_param PATH "$(prompt_path)")"
  hostname_print="$(create_show_param HOSTNAME "\h")"
  user_print="$(create_show_param USER "\u")"
  print_venv="$(create_show_param VENV "$(prompt_venv)")"

  # Since git is a slow command. IF not shouwn then ignore.
  if [ "$ZBASH_CONFIG_SHOW_GIT_BRANCH" != "false" ]; then
    print_git="$(create_show_param GIT_BRANCH "$(prompt_git)")"
  fi

  local print_args=(
    "$clock_print"
    "$print_venv"
    "$print_git"
    "$core_print"
    "$path_print"
    "$user_print"
    "$hostname_print"
  )

  PS1="$(zbash_config_join_by ' ' "${print_args[@]}")${linesep}${ZBASH_CONFIG_COMMAND_LINE_PREFIX}${line_marker}${ZBASH_CONFIG_COLOR_COMMAND_LINE}"

  # PS1="$(join_non_empty_str " " "${print_args[@]}")$linesep${ZBASH_CONFIG_COI_PREFIX}${ret_status}> ${ZBASH_CONFIG_COLOR_COMMAND_LINE}"
}

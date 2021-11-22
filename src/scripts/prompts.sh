#!/bin/bash

function prompt_clock() {
  local format="$ZBASH_CONFIG_CLOCK_FORMAT"
  : "${format:="%H:%M"}"
  date +"$format"
}

function prompt_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    printf "%s" "$(basename "$VIRTUAL_ENV")"
  fi
}

function prompt_path() {
  printf "%s" "$PWD"
}

function prompt_git() {
  zbash_config_is_git_repository || return 0

  zbash_config_fast_git rev-parse --abbrev-ref HEAD
}

function prompt_git_status() {
  zbash_config_is_git_repository || return 0

  local number_of_changes=""
  local number_of_uncommited_changes=""
  local number_of_commited_changes=""

  local all_ok_marker="$ZBASH_COMMONS_GIT_STATUS_ALL_OK_MARKER"
  : "${all_ok_marker:=$'\xE2\x9C\x94'}"

  number_of_uncommited_changes=$(zbash_config_fast_git status --porcelain "$@" | wc -l | xargs) || return 0
  number_of_commited_changes=$(zbash_config_fast_git cherry -v 2>/dev/ | wc -l | xargs) || return 0
  number_of_changes=$((number_of_commited_changes + number_of_uncommited_changes))

  # number_of_changes="$(printf "%02d\n" "$number_of_changes")"
  if [ "$number_of_changes" -eq 0 ]; then
    zbash_config_colorzie "$ZBASH_CONFIG_COLOR_GIT_STATUS_EMPTY" "$all_ok_marker"
  else
    local git_status_color=""
    if [ "$number_of_uncommited_changes" -eq 0 ]; then
      git_status_color="$ZBASH_CONFIG_COLOR_GIT_STATUS_UNPUSHED"
    else
      git_status_color="$ZBASH_CONFIG_COLOR_GIT_STATUS_PENDING"
    fi
    zbash_config_colorzie "$git_status_color" "$(printf "%02d\n" "$number_of_changes")"
  fi
}

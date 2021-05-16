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
  zbash_config_fast_git rev-parse --abbrev-ref HEAD
}

function prompt_git_status() {
  local changed_lines_count=""
  local all_ok_marker="$ZBASH_COMMONS_GIT_STATUS_ALL_OK_MARKER"
  : "${all_ok_marker:=$'\xE2\x9C\x94'}"

  changed_lines_count="$(git status --porcelain | wc -l)" || return 0
  # changed_lines_count="$(printf "%02d\n" "$changed_lines_count")"
  if [ "$changed_lines_count" -eq 0 ]; then
    zbash_config_colorzie "$ZBASH_CONFIG_COLOR_GIT_STATUS_EMPTY" "$all_ok_marker"
  else
    zbash_config_colorzie "$ZBASH_CONFIG_COLOR_GIT_STATUS_PENDING" "$(printf "%02d\n" "$changed_lines_count")"
  fi
}

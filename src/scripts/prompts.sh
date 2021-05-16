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

function prompt_git_status(){
  
}

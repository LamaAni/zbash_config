#!/bin/bash

: "${ZBASH_CONFIG_GIT_WIN_COMMAND_PATH:="git.exe"}"
: "${ZBASH_CONFIG_GIT_COMMAND_PATH:="git"}"

if [ -z "$ZBASH_CONFIG_HAS_GIT_WIN" ]; then
  ZBASH_CONFIG_HAS_GIT_WIN="$(command -v "$ZBASH_CONFIG_GIT_WIN_COMMAND_PATH" 2>&1)"
  if [ $? -eq 0 ]; then
    ZBASH_CONFIG_HAS_GIT_WIN=1
  fi
fi

function zbash_config_get_git_command_path() {
  : "${ZBASH_CONFIG_HAS_GIT_WIN:=1}"
  if [ "$ZBASH_CONFIG_HAS_GIT_WIN" -eq 1 ]; then
    case "$PWD" in
    /mnt/?/*)
      printf "%s" "$ZBASH_CONFIG_GIT_WIN_COMMAND_PATH"
      return
      ;;
    esac
  fi
  printf "%s" "$ZBASH_CONFIG_GIT_COMMAND_PATH"
}

function zbash_config_fast_git() {
  local git_cmd="$(zbash_config_get_git_command_path)"
  "$git_cmd" "$@"
}

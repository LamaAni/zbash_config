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

function zbash_config_is_git_repository() {
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  return 0
}

function zbash_config_fast_git() {
  local git_cmd="$(zbash_config_get_git_command_path)"
  "$git_cmd" "$@"
}

function git_acp() {
  case "$1" in
  -h | --help)
    echo "Git add commit and push integrated command. 
Usage: git_acp my complicated \"message text\""
    return 0
    ;;
  esac
  local msg="$(echo "$@")"
  : "${msg:="updated"}"
  git add . && git commit -m "$msg" --allow-empty && git push -u origin HEAD
}

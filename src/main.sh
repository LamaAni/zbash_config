#!/bin/bash

# Main file, used for bash entry.

function zbash_config_run_command() {
  # Loading helper methods.
  load_zbash_commons

  HELP="
USAGE: zbash_config [command] [.bashrc file]
COMMAND:
  install           Install the config @ the specified .bashrc file. (Or the end of any other bash file). Defaults to COMMAND.
  configure-shell   Called from .bashrc to configure the shell. (Do not call directly)
INPUT:
  [.bashrc file]  The bash rc file to augment. Defaults to BASH_RC_PATH='$HOME/.bashrc'
FLAGS:
  --clear   Clear any other bashrc contents and replace it with the zbash-config. Defaults to CLEAR_BASH_RC_CONTENT
"
  : "${BASH_RC_PATH:="$HOME/.bashrc"}"
  CLEAR_BASH_RC_CONTENT="false"
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -h | --help)
      log:help "$HELP"
      return 0
      ;;
    --clear)
      CLEAR_BASH_RC_CONTENT="true"
      ;;
    *)
      : "${positional:=0}"
      case $positional in
      0)
        COMMAND="$1"
        ;;
      1)
        BASH_RC_PATH="$1"
        ;;
      *)
        assert 2 "Invalid input: $1" || return $?
        ;;
      esac
      positional=$((positional + 1))
      ;;
    esac
    shift
  done

  [ -n "$COMMAND" ]
  assert $? "Command must be defined" || return $?

  [ -f "$BASH_RC_PATH" ]
  assert $? ".bashrc file not found @ $BASH_RC_PATH" || return $?

  if [ "$CLEAR_BASH_RC_CONTENT" == 'true' ]; then
    echo "#!$(which bash)" >|"$BASH_RC_PATH"
  fi

  echo $'\n# INITIALIZE zbash_config\n'"${BASH_SOURCE[0]} configure-shell"$'\n\n' >>"$BASH_RC_PATH"
}

function zbash_config_configure_shell() {
  if [ "$(zbash_config_is_internactive)" == "false" ] && [ "$ZBASH_CONFIG_LOAD_ALWAYS" != "true" ]; then
    return 0
  fi

  zbash_config_configure || return $?
  zbash_config_set_prompt_command || return $?
}

function reset_errored_prompt() {
  export PROMPT_COMMAND=""
  export PS1="ERROR IN SHELL \h \u>"
}

if [ "$1" != "configure-shell" ]; then
  zbash_config_run_command "$@" || exit $?
else
  zbash_config_configure_shell || reset_errored_prompt
fi

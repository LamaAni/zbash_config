#!/bin/bash

# Main file, used for bash entry.

function __run_config_as_command() {
  # Loading helper methods.
  load_zbash_commons

  HELP="
Build and upload the docker image. 

USAGE: zbsh-config [command] [.bashrc file]
COMMAND:
  install   Install the config @ the specified .bashrc file. (Or the end of any other bash file). Defaults to COMMAND.
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
}

if [ "$1" != "load_library" ]; then
  __run_config_as_command "$@" || exit $?
else
  confgure_environment || exit $?
fi

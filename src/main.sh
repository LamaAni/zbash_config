#!/bin/bash
type realpath &>/dev/null
if [ $? -ne 0 ]; then
  function realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi

function zbash_config_run_command() {
  # Main file, used for bash entry.

  # Loading helper methods.
  load_zbash_commons

  HELP="
USAGE: zbash_config [command] [.bashrc file]
COMMAND:
  install           Install the config @ the specified .bashrc file. (Or the end of any other bash file). Defaults to COMMAND.
  configure-shell   Called from .bashrc to configure the shell. (Do not call directly)
INPUT:
  [.bashrc file]  The bash rc file to augment. Defaults to BASH_RC_PATH='$HOME/.bash_profile' (mac) or '$HOME/.bashrc' (other)
FLAGS:
  --clear   Clear any other bashrc contents and replace it with the zbash-config. Defaults to CLEAR_BASH_RC_CONTENT
"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    : "${BASH_RC_PATH:="$HOME/.bash_profile"}"
  else
    : "${BASH_RC_PATH:="$HOME/.bashrc"}"
  fi

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

  local script_path=""
  local init_command=""
  local newline=$'\n'

  [ -n "$COMMAND" ]
  assert $? "Command must be defined" || return $?

  # Validating bash rc.
  [ -f "$BASH_RC_PATH" ] || touch "$BASH_RC_PATH"

  script_path="$(realpath "${BASH_SOURCE[0]}")"
  assert $? "Failed to find script path" || return $?

  init_command="ZBASH_CONFIG_INIT_SCRIPT_ENABLED=true source $script_path configure-shell"

  BASH_RC_SCRIPT="$(cat "$BASH_RC_PATH")"
  echo "$BASH_RC_SCRIPT" >|"$BASH_RC_PATH.$(date +"%Y_%m_%d_%I_%M_%p").back"

  if [ "$CLEAR_BASH_RC_CONTENT" == 'true' ]; then
    BASH_RC_SCRIPT="#!$(which bash)"
  else
    # removing the script if any
    BASH_RC_SCRIPT="$(echo "$BASH_RC_SCRIPT" | grep -v "ZBASH_CONFIG_INIT_SCRIPT_ENABLED=")"
  fi

  BASH_RC_SCRIPT="$BASH_RC_SCRIPT${newline}${init_command}"

  echo "$BASH_RC_SCRIPT" >|"$BASH_RC_PATH"
  assert $? "Failed to write bashrc script"
  log:info "zbash_config installed. You may need to start a new ternminal (> bash)"
}

function zbash_config_configure_shell() {
  if [ "$(zbash_config_is_internactive)" == "false" ] && [ "$ZBASH_CONFIG_LOAD_ALWAYS" != "true" ]; then
    return 0
  fi

  zbash_config_configure || return $?
  zbash_config_set_prompt_command || return $?
}

function reset_errored_prompt() {
  zbash_prompt_COMMAND=""
  PS1="ERROR IN SHELL \h \u>"
}

if [ "$#" -ne 0 ] && [ "$1" != "configure-shell" ]; then
  zbash_config_run_command "$@" || exit $?
else
  zbash_config_configure_shell || reset_errored_prompt
fi

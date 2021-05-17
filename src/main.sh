#!/bin/bash

type realpth &>/dev/null
if [ $? -ne 0 ]; then
  function realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi

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

  local script_path="$(realpath "${BASH_SOURCE[0]}")"

  local init_command="ZBASH_CONFIG_INIT_SCRIPT_ENABLED=true source $script_path configure-shell"

  local already_installed=""
  if [ "$CLEAR_BASH_RC_CONTENT" == 'true' ]; then
    echo "#!$(which bash)" >|"$BASH_RC_PATH"
  else
    already_installed="$(cat "$BASH_RC_PATH" | grep "ZBASH_CONFIG_INIT_SCRIPT_ENABLED=")"
  fi

  if [ -n "$already_installed" ]; then
    local BASH_RC_SCRIPT="$(cat $BASH_RC_PATH)"
    BASH_RC_SCRIPT="$(echo "$BASH_RC_SCRIPT" | sed -E "s/ZBASH_CONFIG_INIT_SCRIPT_ENABLED=.*/<<ZBASH_CONFIG_REPLACE_MARKER>>/gm")"
    BASH_RC_SCRIPT="${BASH_RC_SCRIPT/<<ZBASH_CONFIG_REPLACE_MARKER>>/$init_command}"
    echo "$BASH_RC_SCRIPT" >|"$BASH_RC_PATH"
    # sed -i -E "s/#\s*ZBASH_CONFIG_INIT_SCRIPT_MARKER.*ZBASH_CONFIG_INIT_SCRIPT_MARKER/\{\{REPLACE_ME_MARKER\}\}/g" "$BASH_RC_PATH"
  else
    echo "$init_command" >>"$BASH_RC_PATH"
  fi

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
  export PROMPT_COMMAND=""
  export PS1="ERROR IN SHELL \h \u>"
}

if [ "$1" != "configure-shell" ]; then
  zbash_config_run_command "$@" || exit $?
else
  zbash_config_configure_shell || reset_errored_prompt
fi

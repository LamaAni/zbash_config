#!/bin/bash

function zbash_config_configure() {
  zbash_config_configure_core_bash &&
    zbash_config_configure_completions &&
    zbash_config_configure_aliases || return $?
}

function zbash_config_configure_core_bash() {
  if [ "$ZBASH_CONFIG_CONFIGURE_CORE_BASH" == "false" ]; then return; fi

  # Configure history
  export HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
  shopt -s histappend           # append to the history file, don't overwrite it
  HISTSIZE=1000                 # lenght of history
  HISTFILESIZE=2000             # length of history file

  # terminal
  shopt -s checkwinsize # Recheck the window size after each command

  # Recommended by ununtu.
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # make less more friendly for non-text input files, see lesspipe(1)
}

function zbash_config_configure_completions() {
  if [ "$ZBASH_CONFIG_CONFIGURE_COMPLETIONS" == "false" ]; then return; fi

  if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi

  # Some distribution makes use of a profile.d script to import completion.
  if [ -f /etc/profile.d/bash_completion.sh ]; then
    source /etc/profile.d/bash_completion.sh
  fi

  # homebrew completion
  if command -v brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)

    if [ -f "$BREW_PREFIX"/etc/bash_completion ]; then
      . "$BREW_PREFIX"/etc/bash_completion
    fi

    # homebrew/versions/bash-completion2 (required for projects.completion.bash) is installed to this path
    if [ -f "$BREW_PREFIX"/share/bash-completion/bash_completion ]; then
      . "$BREW_PREFIX"/share/bash-completion/bash_completion
    fi
  fi
}

function zbash_config_configure_aliases() {
  if [ "$ZBASH_CONFIG_CONFIGURE_ALIASES" == "false" ]; then return; fi

  alias l="ls -la"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
}

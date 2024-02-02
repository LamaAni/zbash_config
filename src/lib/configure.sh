#!/bin/bash
function zbash_config_configure() {
  zbash_config_configure_home_envs &&
    zbash_config_configure_core_bash &&
    zbash_config_configure_history &&
    zbash_config_configure_completions &&
    zbash_config_configure_aliases || return $?
}

function zbash_config_configure_core_bash() {
  if [ "$ZBASH_CONFIG_CONFIGURE_CORE_BASH" == "false" ]; then return; fi

  # terminal
  shopt -s checkwinsize # Recheck the window size after each command

  # Recommended by ununtu.
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" # make less more friendly for non-text input files, see lesspipe(1)

  return 0
}

function zbash_config_configure_history() {
  if [ "$ZBASH_CONFIG_CONFIGURE_HISTORY" == "false" ]; then return; fi

  if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.bash_history
  fi

  # Configure history
  shopt -s histappend                             # append to the history file, don't overwrite it
  shopt -s cmdhist                                # Save multi-line commands as one command
  shopt -s histreedit                             # use readline on history
  shopt -s lithist                                # save history with newlines instead of ; where possible
  shopt -s histverify                             # load history line onto readline buffer for editing
  HISTCONTROL=ignoreboth                          # don't put duplicate lines or lines starting with space in the history.
  HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear" # Don't record some commands
  HISTSIZE=1000                                   # lenght of history
  HISTFILESIZE=2000                               # length of history file

  # Use standard ISO 8601 timestamp
  # %F equivalent to %Y-%m-%d
  # %T equivalent to %H:%M:%S (24-hours format)
  HISTTIMEFORMAT='%F %T '

  # Enable incremental history search with up/down arrows (also Readline goodness)
  # Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-hi
  # bash4 specific ??
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\e[5~": previous-history'
  bind '"\e[6~": next-history'
  # bind '"\e[C": forward-char'
  # bind '"\e[D": backward-char'
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
  if [[ "$OSTYPE" != "darwin"* ]]; then
    alias l="ls -la"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
  fi
}

function zbash_config_configure_home_envs() {
  if [ -f "$HOME/.env" ]; then
    source "$HOME/.env"
  fi
}

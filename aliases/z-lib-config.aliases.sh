#!/usr/bin/env bash
if [[ "$(uname -s)" != *"Darwin"* ]]; then
    alias ls="ls --color=auto"
    alias l="ls -la --color=auto"
    alias grep="grep --color=auto"
else
    alias l="ls -la"
fi

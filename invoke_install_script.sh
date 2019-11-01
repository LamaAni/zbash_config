#!/usr/bin/env bash
export LIB_PATH="$PWD/src"
whoami
runpath="$LIB_PATH/install"
source "$runpath" "$@" || exit $?
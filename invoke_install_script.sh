#!/usr/bin/env bash
export LIB_PATH="$PWD/src"
runpath="$LIB_PATH/install"
cat "$runpath"
source "$runpath" "$@" || exit $?
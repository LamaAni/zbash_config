#!/usr/bin/env bash
runpath="$PWD/src/install"
chmod +x "$runpath"
"$runpath" "$@" || exit $?
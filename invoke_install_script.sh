#!/usr/bin/env bash
echo "$PWD"
ls -la
"$PWD/src/install" "$@" || exit $?
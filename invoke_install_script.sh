#!/usr/bin/env bash
cur_path="$(dirname ${BASH_SOURCE[0]})"
echo "Running @ $cur_path"
echo "$PWD"
"$cur_path/src/install" "$@" || exit $?
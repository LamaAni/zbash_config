#!/usr/bin/env bash
cur_path="$(dirname ${BASH_SOURCE[0]})"
"$cur_path/src/install" "$@" || exit $?
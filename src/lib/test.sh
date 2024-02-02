#!/bin/bash

function assert() {
  local code="$1"
  shift
  if [ "$code" -ne 0 ]; then
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][zbash][ERROR]" "$@"
  fi
  return $code
}

function log:info() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][zbash][INFO]" "$@"
}

function zbash_config_test_counts() {
  local counts="$ZBASH_CONFIG_TEST_CYCLE_COUNT"
  : "${counts:="100"}"
  echo "$counts"
}

function zbash_config_test_method_call() {
  for i in $(seq 1 "$(zbash_config_test_counts)"); do
    "$@" >>/dev/null
    assert $? " When invoking: " "$@" || return $?
  done
}

function zbash_config_test_git_speed() {
  local counts="$(zbash_config_test_counts)"
  echo "Checking $counts times get git branch"
  time zbash_config_test_method_call zbash_prompt_git || return $?
  echo "Checking $counts times get git status"
  time zbash_config_test_method_call zbash_prompt_git_status || return $?
}

#!/bin/bash

function assert() {
  local code="$1"
  shift
  if [ "$code" -ne 0 ]; then
    echo "[ERROR]" "$@"
  fi
  return $code
}

function test_method_call() {
  local counts="$ZBASH_CONFIG_TEST_CYCLE_COUNT"
  : "${counts:="100"}"

  for i in $(seq 1 $counts); do
    "$@" >>/dev/null
    assert $? " When invoking: " "$@" || return $?
  done
}

function zbash_config_test_git_speed() {
  test_method_call
  zbash_config_fast_git
}

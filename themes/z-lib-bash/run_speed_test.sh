#!/bin/bash
SCRIPT_PATH=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
source "$SCRIPT_PATH/common.sh"
source "$SCRIPT_PATH/z-lib-bash.theme.sh"

: "${CYCLE_COUNT:=1}"


full_status_result="$(git_command_with_wsl status --porcelain -b)"

function assert(){
    local code="$1"
    shift
    if [ "$code" -ne 0 ]; then
        echo "[ERROR]" "$@" 
    fi
    return $code
}

function test_method_call(){
    local method="$1"
    for i in $(seq 1 $CYCLE_COUNT); do
        $method >> /dev/null
        assert $? " When calling '$method'" || return $?
    done
}


echo "get_lines_in_string:"
time test_method_call 'get_lines_in_string "$full_status_result"'
assert $? "Test failed" || exit $?


echo "parse_git_info:"
time test_method_call 'parse_git_info "$full_status_result"'
assert $? "Test failed" || exit $?


echo "git:"
time test_method_call "git status --porcelain -b"
assert $? "Test failed" || exit $?

echo "git_command_with_wsl:"
time test_method_call "git_command_with_wsl status --porcelain -b"
assert $? "Test failed" || exit $?

echo
echo "get_git_info:"
time test_method_call "get_git_info"
assert $? "Test failed" || exit $?

echo
echo "git_prompt:"
time test_method_call "git_prompt"
assert $? "Test failed" || exit $?

echo
echo "prompt_command:"
time test_method_call "prompt_command"
assert $? "Test failed" || exit $?
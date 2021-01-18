#!/usr/bin
SCRIPT_PATH=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
source "$SCRIPT_PATH/common.sh"

: "${CYCLE_COUNT:=100}"

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

echo "git:"
time test_method_call "git status"
assert $? "Test failed" || exit $?

echo "git_command_with_wsl:"
time test_method_call "git_command_with_wsl status"
assert $? "Test failed" || exit $?

echo
echo "git_prompt:"
time test_method_call "git_prompt"
assert $? "Test failed" || exit $?


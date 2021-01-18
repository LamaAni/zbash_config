#!/usr/bin/env bash
command -v git.exe &>/dev/null
if [ $? -eq 0 ]; then
    ZLIB_BASH_HAS_GIT_EXE=1
fi

function has_git_exec(){
  command -v git.exe &>/dev/null
if [ $? -eq 0 ]; then
    export ZLIB_BASH_HAS_GIT_EXE=1
fi  
}

function read_from_pipe() { 
    if [[ -p /proc/self/fd/0 ]]; then
        printf "%s" "$(cat -)"
        return 0
    else
        return 1
    fi
}

function git_use_exec() {
    if [ $ZLIB_BASH_HAS_GIT_EXE -eq 1 ]; then
        case "$PWD" in
        /mnt/?/*)
            printf "%s" "true"
            return 0
            ;;
        esac
    fi
    printf "%s" "false"
    return 1
}

function git_command_with_wsl() {
    if [ "$(git_use_exec)" == "true" ]; then
        git.exe "$@" || return $?
        # printf 'git.exe "$@" || exit $?' | bash -s "$@" || return $?
        # bash -c 'git.exe "$@"' -- "$@" || return $?
    else
        git "$@" || return $?
    fi
}

function trim_str() {
     printf "%s" "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

function jon_str() {
    local with="$1"
    shift
    local arr=("$@")
    local jon_stred=""
    local is_first=1
    for v in "${arr[@]}"; do
        if [ $is_first -ne 1 ]; then
            jon_stred="$jon_stred$with"
        fi
        is_first=0
        jon_stred="$jon_stred$v"
    done
    printf "%s" "$jon_stred"
}

# OVERRIDE: the git name resolve. (_ should be here)
# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch() {
    local unsafe_ref
    unsafe_ref="$(git_command_with_wsl symbolic-ref -q HEAD 2>/dev/null)" || return $?
    local stripped_ref=${unsafe_ref##refs/heads/}
    local clean_ref=${stripped_ref//[^a-zA-Z0-9\/_]/-}
    printf "%s" "$clean_ref"
}

function get_git_info(){
    local info=$(git_command_with_wsl git status --porcelain -b) || return $?
    local branch="$(echo "$info"|head -n 1| grep -Eo "[a-zA-Z0-9].*[.]{3}")"
    branch="${branch::-3}"
    echo "$branch"
}

function git_prompt() {
    local ref
    local is_git_repo=1
    local status
    local git_status_flags=('--porcelain')
    ref="$(git_clean_branch)" || is_git_repo=0
    if [ $is_git_repo -eq 1 ]; then
        status="$(git_command_with_wsl status ${git_status_flags} 2>/dev/null | tail -n1)"

        if [ -n "$status" ]; then
            status="$SCM_THEME_PROMPT_DIRTY"
        else
            status="$SCM_THEME_PROMPT_CLEAN"
        fi

        printf "%s" "${SCM_THEME_PROMPT_PREFIX}${ref}${status}${SCM_THEME_PROMPT_SUFFIX}"
    fi
}
#!/usr/bin/env bash
: "${ZLIB_BASH_GIT_BRANCH_REGEX:="^[ ]*##[ ]*([a-zA-Z0-9].*?)$"}"
: "${ZLIB_BASH_GIT_REMOTE_BRANCH_SPLIT:="(.*?)[.]{3}.*$"}"
: "${ZLIB_BASH_GIT_TRIM_REGEX:="^\s*(.*?)\s*$"}"

if [ -z "$ZLIB_BASH_HAS_GIT_EXE" ]; then
    command -v git.exe &>/dev/null
    if [ $? -eq 0 ]; then
        ZLIB_BASH_HAS_GIT_EXE=1
    fi
fi

function regex_match() {
    local regex="$1"
    local val="$2"
    local idx="$3"
    [[ "$val" =~ $regex ]]
    if [ -n "$idx" ]; then
        printf "%s" "${BASH_REMATCH[idx]}"
    else
        echo "${BASH_REMATCH[@]}"
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

function assert() {
    local code="$1"
    shift
    if [ "$code" -ne 0 ]; then
        echo >&2 "[Error]" "$@"
    fi
    return $?
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
    regex_match "$ZLIB_BASH_GIT_TRIM_REGEX" "$1" 1
}

function join_non_empty_str() {
    local sep="$1"
    local val=""
    shift
    while [ "$#" -gt 0 ]; do
        val="$(trim_str "$1")"
        shift
        if [ -z "$val" ]; then
            continue
        fi
        printf "%s" "$val"
        if [ "$#" -ne 0 ]; then
            printf "%s" "$sep"
        fi
    done
}

function join_str() {
    local sep="$1"
    shift
    while [ "$#" -gt 0 ]; do
        printf "%s" "$1"
        shift
        if [ "$#" -ne 0 ]; then
            printf "%s" "$sep"
        fi
    done
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

function get_lines_in_string() {
    local txt="$1"
    local IFS=$'\n'
    local all_lines=($txt)
    local count="${#all_lines[@]}"
    printf "$count"
}

function parse_git_info() {
    local info="$1"
    local ref="$(regex_match "$ZLIB_BASH_GIT_BRANCH_REGEX" "$info" 1)"
    ref_just_branch="$(regex_match "$ZLIB_BASH_GIT_REMOTE_BRANCH_SPLIT" "$ref" 1)"
    if [ -n "$ref_just_branch" ]; then
        ref="$ref_just_branch"
    fi

    : "${ref:="??"}"

    local info_lines="$(get_lines_in_string "$info")"
    local status="clear"
    if [ "$info_lines" -gt 1 ]; then
        status="pending"
    fi

    printf "%s %s" "$ref" "$status"
}

function get_git_info() {
    local info=""
    info="$(git_command_with_wsl status --porcelain -b 2>&1)" || return 2

    parse_git_info "$info"
}

function git_prompt() {
    local info=""
    info="$(get_git_info)"
    if [ "$?" -ne 0 ]; then
        return 0
    fi
    info=($info)
    local ref="${info[0]}"
    local status="${info[1]}"

    if [ "$status" == "pending" ]; then
        status="$SCM_THEME_PROMPT_DIRTY"
    else
        status="$SCM_THEME_PROMPT_CLEAN"
    fi

    printf "%s" "${SCM_THEME_PROMPT_PREFIX}${ref}${status}${SCM_THEME_PROMPT_SUFFIX}"
}

function mount_file_drives() {
    if [ "$#" -eq 0 ]; then return; fi

    if [ "$#" -eq 1 ]; then
        drives=($@)
        mount_file_drives "${drives[@]}"
        return $?
    fi

    while [ "$#" -gt 0 ]; do
        local src="$1"
        shift
        local dest="$1"
        shift
        [ -n "$src" ]
        assert $? "Source must be defined" || return $?

        [ -n "$dest" ]
        assert $? "destination must be defined" || return $?

        if [ -z "$(mount | grep "$dest")" ]; then
            echo "zlib-bash: Mounting $src -> $dest"
            mount "$src" "$dest"
            assert $? "Failed to mount (check folder & permissions)"
        fi
    done
}

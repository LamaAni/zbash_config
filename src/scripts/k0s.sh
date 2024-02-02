#!/bin/bash
# DO NOT USE EXIT (its a function)
#-# kubernetes k0s cluster commands (helper methods)
export KUBE_HOME="$HOME/.kube"
export K0S_HOME="$HOME/.k0s"
export K0S_CONFIG="$K0S_HOME/k0s.yml"
export K0S_LOG="$K0S_HOME/k0s.log"
export K0S_PID="$K0S_HOME/k0s.pid"

: "${KUBECONFIG:="$KUBE_HOME/config"}"

function validate_config() {
    if [ ! -d "$K0S_HOME" ]; then
        mkdir -p "$K0S_HOME"
        assert $? "Failed to create k0s home @ $K0S_HOME" || return $?
    fi

    if [ ! -f "$K0S_CONFIG" ]; then
        k0s config create >|"$K0S_CONFIG"
        assert $? "Failed to create config file @ $K0S_CONFIG" || return $?
    fi
}

function k0s_install() {
    log:info "Configuring k0s server"
    validate_config
    assert $? "Failed to validate the k0s config" || return $?

    dump="$(type -t kubectl)"
    if [ $? -ne = 0 ]; then
        log:info "Skipped writing kubectl config, kubectl not found"
        return 0
    fi

    log:info "Creating kubectl entery"
    validate_login || return $?

    mkdir -p "$KUBE_HOME"
    assert $? "Failed to validate kubectl home @ $KUBE_HOME" || return $?

    local kubectl_back_config="$KUBE_HOME/config.$(date +%Y-%m-%dT%H:%M:%S%z).zbash.back"
    log:info "Backing up kubectl config @ $KUBECONFIG -> $kubectl_back_config, $KUBE_HOME/config.zbash.back"
    cp "$KUBECONFIG" "$kubectl_back_config" && cp "$KUBECONFIG" "$KUBE_HOME/config.zbash.back"
    assert $? "Failed to back up kube config $KUBECONFIG -> $kubectl_back_config" || return $?

    local config=""
    config="$(sudo k0s kubeconfig admin)" && config="$(echo "$config" | sed -e 's/\bDefault\b/k0s/g' -e 's/\blocal\b/k0s-local/g' -e 's/\buser\b/k0s-user/g')"
    assert $? "Failed to create kubectl entry" || return $?

    local current_config=""
    local new_config=""
    current_config="$(mktemp)" && new_config="$(mktemp)" &&
        cp "$KUBECONFIG" "$current_config" &&
        echo "$config" >|"$new_config"
    assert $? "Failed to creat temp files" || return $?

    local merged_config=""
    merged_config="$(KUBECONFIG="$current_config:$new_config" kubectl config view --flatten)"
    assert $? "Failed to create merged config" || return $?

    echo "$merged_config" >|"$KUBECONFIG"
    assert $? "Failed to write merged config @ $KUBECONFIG" || return $?

    log:info "Install complete"
}

function k0s_stop() {
    log:info "Stopping k0s server"

    [ -f "$K0S_PID" ]
    assert $? "PID file not found, if k0s server is running, you would need to stop that manually" || return $?

    sudo kill "$(cat "$K0S_PID")"
    assert $? "Failed to kill k0s" || return $?

    rm -rf "$K0S_PID"
    assert $? "Failed to delete k0s pid file, you may have to manually do that" || return $?
}

function validate_login() {
    log:info "$(sudo echo "User authenticaed")"
    assert $? "Failed to log in, you must run this command as root" || return $?
}

function k0s_start() {
    [ -f "$K0S_CONFIG" ]
    assert $? "No config file found @ $K0S_CONFIG, please run install first" || return $?

    if [ -f "$K0S_PID" ] && ps -p $(cat $K0S_PID) >/dev/null; then
        assert 3 "k0s servier is already running @ pid = $(cat $K0S_PID)" || return $?
    fi

    function run_cluster() {
        sudo rm -rf "$K0S_LOG"
        assert $? "Failed to delte old log file" || return $?

        # Starting service.
        command=(
            k0s server
            --config "$K0S_CONFIG"
            --enable-worker
        )
        log:info "Starting server with:" "${command[@]}" 1>&2
        local
        if [ "$K0S_START_RUN_SYNC" == "true" ]; then
            sudo "${command[@]}" || return $?
        else
            sudo "${command[@]}" >>"$K0S_LOG" 2>&1 || return $?
        fi
    }
    validate_login || return $?
    command=(
        k0s server
        --config "$K0S_CONFIG"
        --enable-worker
    )
    log:info "Starting server with:" "${command[@]}" 1>&2
    if [ "$K0S_START_RUN_SYNC" == "true" ]; then
        sudo "${command[@]}" &
    else
        sudo "${command[@]}" >>"$K0S_LOG" 2>&1 &
    fi
    local pid="$!"

    echo "$pid" >|"$K0S_PID"
    assert $? "Faile to start and register PID, you must stop the server manually"

    log:info "Written k0s pid $pid @ $K0S_PID"

    if [ "$K0S_START_RUN_SYNC" == "true" ]; then
        wait $pid
        rm -rf "$K0S_PID"
        assert $? "PID file missing, was it removed elsewhere?"
    else
        log:info "Service started"
    fi
}

function main() {
    HELP="
USAGE: zbash k0s [command]
COMMANDS:
    install         Install the dev k0s environment, fast usage
    start           Run the dev k0s server, in the background without a service (If service use native)
    stop            Stop the k0s executing server
FLAGS:
    -h | --help     Show this help menu
    --sync          Run the server command in sync mode (dump logs to stdout)
"

    K0S_COMMAND=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
        --help | -h)
            echo "$HELP"
            return 0
            ;;
        --sync)
            export K0S_START_RUN_SYNC="true"
            ;;
        install | start | stop)
            K0S_COMMAND="$1"
            ;;
        *)
            assert 2 "Command not found" | return $?
            ;;
        esac
        shift
    done

    [ -n "$K0S_COMMAND" ]
    assert $? "Please provide a k0s command to execute" || return $?

    dump="$(type -t k0s 2>&1)"
    assert $? "k0s command not found, and must be installed in the system" || return $?

    case "$K0S_COMMAND" in
    start)
        k0s_start
        ;;
    stop)
        k0s_stop
        ;;
    install)
        k0s_install
        ;;
    esac
}

main "$@"

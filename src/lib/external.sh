#!/bin/bash
function load_zbash_commons() {
  type assert &>/dev/null
  if [ $? -ne 0 ] || [ "$ZBASH_COMMONS_LIB_LOADED" != "true" ]; then
    type zbash_commons &>/dev/null
    if [ $? -ne 0 ]; then
      echo "[DOWNLOAD] Downloading zbash_commons from latest release.." 1>&2
      ZBASH_COMMONS_GET_SCRIPT="$(curl -Ls "https://raw.githubusercontent.com/LamaAni/zbash-commons/master/get?ts_$(date +%s)=$RANDOM")"
      ZBASH_COMMONS="$(bash -c "$ZBASH_COMMONS_GET_SCRIPT")"
      eval "$ZBASH_COMMONS"
    else
      source zbash_commons
    fi
  fi
}

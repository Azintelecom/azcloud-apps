#!/usr/bin/env bash

APP_PATH="$1"; [ -z $APP_PATH ] && { echo "app not found"; exit 1; }
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
APP_PROXY="$(cat .proxy)"
export HTTP_PROXY="${APP_PROXY}" bash -x "${APP_DIR}/${APP_PATH}"/app.sh >> /tmp/azcloud-apps/"${APP_PATH##*/}".log 2>&1

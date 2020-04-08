#!/usr/bin/env bash

APP_PATH="$1"; [ -z $APP_PATH ] && { echo "app not found"; exit 1; }
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
sudo bash "${APP_DIR}/${APP_PATH}"/app.sh  

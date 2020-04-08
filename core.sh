#!/usr/bin/env bash

APP_PATH="$1"; [ -z $APP_PATH ] && { echo "app not found"; exit 1; }
sudo bash "${APP_PATH}"/app.sh  

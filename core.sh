#!/usr/bin/env bash

load_module()
{
  local app_path; app_path="$1"
  find "$app_path" -type f ! -name \*main\* -a ! -name \*.sh\* \
    | while read -r file; do source "$file"; done
}

main()
{
  APP_PATH="$1"; [ -z $APP_PATH ] && { echo "app not found"; exit 1; }
  APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >& /dev/null && pwd )"
  APP_PROXY="$(cat $APP_DIR/.proxy)"
  load_module "${APP_DIR}"/"${APP_PATH}"
  export PROXY="${APP_PROXY}"
  bash -x "${APP_DIR}"/"${APP_PATH}"/main >> /tmp/azcloud-apps/app.log 2>&1
}

main "$@"

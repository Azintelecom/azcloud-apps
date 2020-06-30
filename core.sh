#!/usr/bin/env bash

load_module()
{
  local app_path; app_path="$1"
  # shellcheck disable=SC2044
  for module in $(find "$app_path" -type f ! -name \*.sh\*); do
    # shellcheck disable=SC1090
    source "$module"
  done
}

main()
{
  set -x
  local app_path app_dir app_proxy run_module
  app_path="$1"; [ -z "$app_path" ] && { echo "app not found"; exit 1; }
  app_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >& /dev/null && pwd )"
  app_proxy="$(cat "$app_dir"/.proxy)"
  export PROXY="${app_proxy}"
  load_module "${app_dir}"/_variables
  load_module "${app_dir}"/_functions
  load_module "${app_dir}"/"${app_path}"
  install_dependencies || fatal "Could not install dependencies"
  run_module=${app_path////_}; run_module=${run_module//+/_}
  azapps_"$run_module" >> "$AZCLOUD_APPS_HOME"/app.log 2>&1
}

main "$@"

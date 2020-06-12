#!/usr/bin/env bash

fatal()
{
  echo "ERROR: $*" >&2
  exit 1
}

load_module()
{
  local app_path; app_path="$1"
  for module in $(find "$app_path" -type f ! -name \*.sh\*); do
    source $module
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
  load_module "${app_dir}"/"${app_path}"
  run_module=${app_path////_}; run_module=${run_module//+/_}
  azapps_"$run_module" >> /tmp/azcloud-apps/app.log 2>&1
}

main "$@"

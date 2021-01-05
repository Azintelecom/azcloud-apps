#!/usr/bin/env bash

fatal()
{
  echo "ERROR: $*"
  exit 1
}

main()
{
  local latest_version;
  latest_version="$(curl -sL https://download.nextcloud.com/server/releases \
                      | sed 's@.*href=@@; s@>.*@@; s@"@@g; s@nextcloud-@@g' \
                      | grep zip$ \
                      | sed 's@\.zip@@g' \
                      | tail -n1)"

  [ -z "$latest_version" ] && fatal "could not detect nextcloud latest version"
  local curr_version;
  installed_version="$(sudo su - apache -s /bin/bash -c \
                    'cd /var/www/html/nextcloud && php occ -V' \
                    | awk '{print $NF}')"
  [ -z "$installed_version" ] && fatal "could not detect nextcloud installed version"
  if [[ "${installed_version%%.*}" != "${latest_version%%.*}" ]]; then
    echo "nexclout new version: $latest_version available"
    echo "installed version: $installed_version"
  fi
}

main

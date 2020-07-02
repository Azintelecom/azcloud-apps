#!/usr/bin/env bash

_join_starting()
{
  cat <<EOF > ${AZCLOUD_APPS_LOG}/join.log
> Joining cluster:
    host: $hostname
    time: $(date)
    join: started
EOF
}

_join_success()
{
  sed -i '/join/s/started/success/g' "$AZCLOUD_APSS_HOME"/join.log
}

_join_error()
{
  sed -i '/join/s/started/error/g' "$AZCLOUD_APPS_HOME"/join.log
}

_join_cluster()
{
  until [ -f "$AZCLOUD_APPS_HOME"/ready ] || [ $((++_c)) -gt 120 ]; do sleep 5; done
  systemctl start mariadb
}

main()
{
  _join_starting
  _join_cluster && _join_success || _join_error
}

main

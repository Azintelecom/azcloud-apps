#!/usr/bin/env bash

_join_starting()
{
  cat <<EOF > /tmp/azcloud-apps/join.log
> Joining cluster:
    host: $hostname
    time: $(date)
    join: started
EOF
}

_join_success()
{
  sed -i '/join/s/started/success/g' /tmp/azcloud-apps/join.log
}

_join_error()
{
  sed -i '/join/s/started/error/g' /tmp/azcloud-apps/join.log
}

_join_cluster()
{
  until [ -f /tmp/azcloud-apps/ready ] || [ $((++_c)) -gt 120 ]; do sleep 5; done
  systemctl start mariadb
}

main()
{
  set -x
  _join_starting
  _join_cluster && _join_success || _join_error
}

main

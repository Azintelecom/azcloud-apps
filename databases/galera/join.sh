#!/usr/bin/env bash

_banner()
{
  cat <<EOF
> Joining cluster:
    host: $hostname
    time: $(date)
    join: started
EOF
}

_join_cluster()
{
  until [ -f /tmp/azcloud-apps/ready ] || [ $((++_c)) -gt 120 ]; do sleep 5; done
  systemctl start mariadb
}

main()
{
  _banner
  _join_cluster
}

main

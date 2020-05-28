#!/usr/bin/env bash

export HTTP_PROXY="$PROXY"
export HTTPS_PROXY="$PROXY"
export http_proxy="$PROXY"
export https_proxy="$PROXY"

fatal()
{
  echo "ERROR: $*" >&2
  exit 1
}

_setup_firewall_and_selinux()
{
  :
}

_setup_docker_repo()
{
  :
}

_install_docker()
{
  curl -fsSL https://get.docker.com/ | sh
}

_setup_users_to_use_docker()
{
  for user in $(cut -d: -f1,3 /etc/passwd | sort -n -t: -k2,2); do 
    if [ "${user##*:}" -ge 1000 ]; then
      usermod -aG docker "${user%%:*}"
    fi
  done
}

_start_docker()
{
  systemctl enable --now docker
}

main()
{
  _setup_firewall_and_selinux
  _setup_docker_repo
  _install_docker
  _setup_users_to_use_docker
  _start_docker
}

main
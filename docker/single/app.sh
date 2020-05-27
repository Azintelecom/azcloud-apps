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

main()
{
  _setup_firewall_and_selinux
  _setup_docker_repo
  _install_docker
}

main

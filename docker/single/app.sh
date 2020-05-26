#!/usr/bin/env bash

export HTTP_PROXY="$PROXY"
export HTTPS_PROXY="$PROXY"

_set_proxy()
{
  export http_proxy="$HTTP_PROXY"
  export https_proxy="$HTTPS_PROXY"
  export HTTP_PROXY="$HTTP_PROXY"
  export HTTPS_PROXY="$HTTPS_PROXY"
}

_unset_proxy()
{
  unset http_proxy
  unset https_proxy
  unset HTTP_PROXY
  unset HTTPS_PROXY
}


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
  :
}

main()
{
  _setup_firewall_and_selinux
  _setup_docker_repo
  _install_docker
}

main

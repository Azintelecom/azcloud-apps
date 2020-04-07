#!/usr/bin/env bash
#
# dummy script that should install and configure
# one single mariabd instance
# 

PROXY="http://proxy.azcloud.az:3128"
HTTP_PROXY="$PROXY"
HTTPS_PROXY="$PROXY"

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

_prereq()
{
  _set_proxy
  sudo -E yum -y install git
  git clone https://github.com/azintelecom/azcloud-apps /tmp/apps
  _unset_proxy
}

_install_app()
{
  _set_proxy
  sudo -E yum -y install mariadb mariadb-server expect
  _unset_proxy
}

_deploy_app()
{
  local mysql_root_password="$1"; shift
  local mysql_curr_password=""

  secure_mysql=$(expect -c "
set timeout 5
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$mysql_curr_password\r\"
expect \"Set root password?*\"
send \"y\r\"
expect \"New password*\"
send \"$mysql_root_password\r\"
expect \"Re-enter new password*\"
send \"$mysql_root_password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$secure_mysql"
}

main()
{
  _prereq
  _install_app
  _deploy_app "$@"
}

main "$@"

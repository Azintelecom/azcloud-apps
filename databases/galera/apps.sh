#!/usr/bin/env bash

fatal()
{
  echo "ERROR: $*" >&2
  exit 1
}

_get_nodes_addresses()
{
  local addresses;
  addresses=($(vmtoolsd --cmd "info-get guestinfo.appdata" | base64 -d | jq -r .vms[].net[].address))
  [ -z "$addresses" ] && fatal "Could not get nodes addresses"
  echo "${addresses[@]}"
}

_install_galera_centos()
{
  cat <<'EOF' > /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
  
  yum makecache --disablerepo='*' --enablerepo='mariadb'
  yum install -y MariaDB-server MariaDB-client
  yum install -y rsync policycoreutils-python
  systemctl enable --now mariadb
}

_set_galera_config()
{
  local nodes; nodes="$(_get_nodes_addresses | sed 's@ @,@g')"
  local cluster_name; cluster_name="$(hostname -s | awk -F- '{print $(NF-2)}')"
  local hostname; hostname="$(hostname -s)"
  local address; address="$(ip addr sh ens192 | awk '/inet /{print $2}' | cut -d/ -f1)"

  cat <<EOF > /etc/my.cnf.d/galera.cnf
[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

# Galera Provider Configuration
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so

# Galera Cluster Configuration
wsrep_cluster_name="$cluster_name"
wsrep_cluster_address="gcomm://$nodes"

# Galera Synchronization Configuration
wsrep_sst_method=rsync

# Galera Node Configuration
wsrep_node_address="$address"
wsrep_node_name="$hostname"
EOF
}

main()
{
  #_install_galera_centos
}

main


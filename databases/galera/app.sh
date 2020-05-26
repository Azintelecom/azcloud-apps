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

_get_nodes_addresses()
{
  local addresses;
  addresses=($(vmtoolsd --cmd "info-get guestinfo.appdata" | base64 -d | jq -r .vms[].net[].address))
  [ -z "$addresses" ] && fatal "Could not get nodes addresses"
  echo "${addresses[@]}"
}

_setup_galera_storage()
{
  local disks; disks=($(lsblk | grep sd[b-z] | awk '{print $1}' | sed 's@^@/dev/@g'))
  [ -z "$disks" ] && { echo "no disk found"; return 1; }
  sudo vgcreate galera_storage ${disks[*]}
  sudo lvcreate -n mariadb -l 100%VG galera_storage
  sudo mkfs.ext4 /dev/galera_storage/mariadb 
  sudo mkdir -p /var/lib/mysql
  sudo mount /dev/galera_storage/mariadb /var/lib/mysql
}

_install_galera_centos()
{
  local temp_config; temp_config="$(mktemp)"

  cat <<EOF > "$temp_config"
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
  sudo mv "$temp_config" /etc/yum.repos.d/mariadb.repo
  sudo -E yum makecache --disablerepo='*' --enablerepo='mariadb'
  _set_proxy
  sudo -E yum install -y MariaDB-server MariaDB-client rsync policycoreutils-python
  _unset_proxy
  sudo systemctl enable --now mariadb
}

_set_galera_config()
{
  local temp_config; temp_config="$(mktemp)"
  local nodes; nodes="$(_get_nodes_addresses | sed 's@ @,@g')"
  local cluster_name; cluster_name="$(hostname -s | awk -F- '{print $(NF-2)}')"
  local hostname; hostname="$(hostname -s)"
  local address; address="$(ip addr sh ens192 | awk '/inet /{print $2}' | cut -d/ -f1)"

  cat <<EOF > "$temp_config"
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

  sudo mv "$temp_config" /etc/my.cnf.d/galera.cnf
}

main()
{
  _setup_galera_storage
  _install_galera_centos
  _set_galera_config
}

main


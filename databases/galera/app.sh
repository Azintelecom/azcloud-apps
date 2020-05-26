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

_setup_firewall_and_selinux()
{
    if systemctl is-active firewalld | grep -q active; then
      firewall-cmd --permanent --zone=public --add-port=3306/tcp
      firewall-cmd --permanent --zone=public --add-port=4567/tcp
      firewall-cmd --permanent --zone=public --add-port=4568/tcp
      firewall-cmd --permanent --zone=public --add-port=4444/tcp
      firewall-cmd --permanent --zone=public --add-port=4567/udp
    elif command -v iptables >& /dev/null; then
      iptables -I INPUT -p tcp --dport 3306 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
      iptables -I INPUT -p tcp --dport 4567 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT 
      iptables -I INPUT -p tcp --dport 4444 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
      iptables -I INPUT -p tcp --dport 3306 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
      iptables -I INPUT -p udp --dport 4567 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
   fi

   # set domain to permissive mode
   semanage permissive -a mysqld_t
}

_setup_galera_storage()
{
  local disks; disks=($(lsblk | grep sd[b-z] | awk '{print $1}' | sed 's@^@/dev/@g'))
  [ -z "$disks" ] && { echo "no disk found"; return 1; }
   vgcreate galera_storage ${disks[*]}
   lvcreate -n mariadb -l 100%VG galera_storage
   mkfs.ext4 /dev/galera_storage/mariadb 
   mkdir -p /var/lib/mysql
   mount /dev/galera_storage/mariadb /var/lib/mysql
}

_install_galera_centos()
{
  cat <<EOF > /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
  yum makecache --disablerepo='*' --enablerepo='mariadb'
  _set_proxy
  yum install -y MariaDB-server MariaDB-client rsync policycoreutils-python
  _unset_proxy
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
  _setup_firewall_and_selinux
  _setup_galera_storage
  _install_galera_centos
  _set_galera_config
}

main


#!/usr/bin/env bash

export HTTP_PROXY="$PROXY"
export HTTPS_PROXY="$PROXY"
export http_proxy="$PROXY"
export https_proxy="$PROXY"

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

_get_haproxy_address()
{
  local address
  address="$(vmtoolsd --cmd "info-get guestinfo.appdata" | base64 -d | jq -r .apps.config.haproxy)"
  [ -z "$address" ] && fatal "Could not get haproxy address"
  echo "$address"
}

_get_play_id()
{
  local play_id
  play_id="$(hostname -s)"
  play_id="${play_id#*-}"
  play_id="${play_id%%-*}"
  echo "$play_id"
}

_get_nodes()
{
  local play_id; play_id="$(_get_play_id)"
  grep "$play_id" /etc/hosts | awk '{print $NF}'
}

_get_nodes_ips()
{
  local play_id; play_id="$(_get_play_id)"
  grep "$play_id" /etc/hosts | awk '{print $3,$1}'
}

_node_to_address()
{
  local node; node="$1"; shift
  local play_id; play_id="$(_get_play_id)"
  grep "$node-$play_id" /etc/hosts | awk '{print $1}'
}

_get_db_pass()
{
  local db_pass;
  db_pass="$(vmtoolsd --cmd "info-get guestinfo.appdata" | base64 -d | jq -r .apps.config.dbpass)"
  [[ $db_pass == "null" ]] && db_pass="$(_get_play_id)"
  echo "$db_pass"
}

_run_on_node()
{
  local node; node="$1"; shift
  local comm; comm="$@"
  ssh=();ssh=(ssh)
  ssh+=(-o ControlPath=~/.ssh/cm-%r@%h:%p)
  ssh+=(-o ControlMaster=auto)
  ssh+=(-o ControlPersist=10m)
  ssh+=(-o BatchMode=yes)
  ssh+=(-o PreferredAuthentications=publickey)
  ssh+=(-o PubkeyAuthentication=yes)
  ssh+=(-o StrictHostKeyChecking=no)
  ssh+=(root@"$node" -t "$comm")
  ${ssh[@]}
}

_install_deps()
{
  yum -y install tmux jq vim
}

_update_host_file()
{
  local nodes; nodes=($(_get_nodes_addresses))
  local hostname
  echo "# azcloud-apps" >> /etc/hosts
  for node in ${nodes[@]}; do
    hostname="$(_run_on_node "$node" hostname -s)"
    echo "$node" "$hostname" "${hostname%%-*}" >> /etc/hosts
  done
}

_install_avahi_centos()
{
  yum -y install avahi avahi-tools

  mv /etc/avahi/{avahi-daemon.conf,avahi-daemon.conf.orig}
  cat <<'EOF' > /etc/avahi/avahi-daemon.conf
[server]
use-ipv4=yes
use-ipv6=no
deny-interfaces=docker0
ratelimit-interval-usec=1000000
ratelimit-burst=1000

[wide-area]
enable-wide-area=yes

[publish]
publish-hinfo=no
publish-workstation=yes

[reflector]

[rlimits]
EOF
  systemctl restart avahi-daemon

  cat <<'EOF' > /etc/systemd/system/avahi-alias@.service
[Unit]
Description=Publish %I as alias for %H.local via mdns
Wants=avahi-daemon.service

[Service]
Type=simple
ExecStart=/bin/bash -c "/usr/bin/avahi-publish -a -R %I $(avahi-resolve -4 -n %H.local | cut -f 2)"

[Install]
WantedBy=multi-user.target
EOF
  local short; short="$(hostname -s)"; short="${short%%-*}"
  systemctl enable --now avahi-alias@"$short".local.service
}


## HAProxy setup begins here

_is_it_haproxy()
{
  local node; node="$1"; shift
  node="${node%%-*}"; node=$(_node_to_address "$node")
  local haproxy_address; haproxy_address="$(_get_haproxy_address)"
  local haproxy; haproxy=1
  if [ "$haproxy_address" == "$node" ]; then
    haproxy=0
  fi
  return $haproxy
}

_am_i_haproxy()
{
  _is_it_haproxy "$(hostname -s)"
}
 
_install_and_setup_haproxy()
{
  local my_address; my_address="$(hostname -i)"
  yum -y install haproxy keepalived
  mv /etc/haproxy/{haproxy.cfg,haproxy.cfg.orig}
  cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log 127.0.0.1 local0 notice
    user haproxy
    group haproxy

defaults
    log global
    retries 2
    timeout connect 3000
    timeout server 5000
    timeout client 5000

listen galera-cluster
    bind $my_address:3306
    mode tcp
    option mysql-check user haproxy_check
    balance roundrobin
EOF
  IFS=$'\n'
  for node in $(_get_nodes_ips); do
    if [ "${node##* }" != "${my_address}" ]; then
      cat <<EOF >> /etc/haproxy/haproxy.cfg
    server ${node%% *} ${node##* }:3306 check
EOF
    fi
  done

  semanage permissive -a haproxy_t
  systemctl start haproxy
}

## HAProxy setup ends here

## Galera setup starts here
_setup_firewall_and_selinux_galera()
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
      iptables -I INPUT -p tcp --dport 4568 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
      iptables -I INPUT -p tcp --dport 4444 -m comment --comment 'added by azcloud-apps' -m state --state NEW -j ACCEPT
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
  yum install -y MariaDB-server MariaDB-client rsync policycoreutils-python
  systemctl enable --now mariadb
}

_set_mariadb_password_and_haproxy_user()
{
  local mysql_root_password="$(_get_db_pass)"
  local subnet; subnet="$(hostname -i)"; subnet="${subnet%.*}"
  local play_id; play_id="$(_get_play_id)"
  mysql -u root -p' ' -e "FLUSH PRIVILEGES;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${mysql_root_password}');
CREATE USER 'haproxy_check'@'${subnet}.%';
CREATE USER 'haproxy_root'@'${subnet}.%' IDENTIFIED BY '$play_id';
GRANT ALL PRIVILEGES ON *.* TO 'haproxy_root'@'${subnet}%';
FLUSH PRIVILEGES;"
}

_tune_mariadb_systemd()
{
  if [ ! -d /etc/systemd/system/mariadb.service.d ]; then
    mkdir -p /etc/systemd/system/mariadb.service.d
  fi
  cat <<'EOF' > /etc/systemd/system/mariadb.service.d/override.conf
[Service]
LimitNOFILE=65535
LimitMEMLOCK=65535
EOF
  systemctl daemon-reload
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
bind-address=127.0.0.1
ignore-db-dir=lost+found
max_connections=1024
max_allowed_packet=536870912 # half of max
open_files_limit=65536 # can be increased to 1024000

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

_is_it_first()
{
  local node; node="$1"; shift
  local first; first=1
  if [ "${node:(-1)}" = 1 ]; then
    first=0
  fi
  return $first
}

_ready_to_join_cluster()
{
  touch /tmp/azcloud-apps/ready
}

_start_mariadb_on_all_nodes()
{
  local play_id; play_id="$(_get_play_id)"

  local nodes; nodes=($(_get_nodes))
  for node in ${nodes[@]}; do
    if ! _is_it_first "$node" && ! _is_it_haproxy "$node"; then
      _run_on_node "$node" "tmux new-session -d \
        'until [ -f /tmp/azcloud-apps/databases/galera+haproxy/join.sh ] || [ $((++_c)) -gt 120 ]; do sleep 5; done;
         bash /tmp/azcloud-apps/databases/galera+haproxy/join.sh'"
    fi
  done
}

_setup_galera_cluster()
{
  systemctl stop mariadb && _ready_to_join_cluster
  if _is_it_first "${HOSTNAME%%-*}"; then
    galera_new_cluster && _start_mariadb_on_all_nodes
  fi
}

_get_cluster_size()
{
  mysql -u root -p' ' -e "SHOW STATUS LIKE 'wsrep_cluster_size'" \
    | sed 's/\t/,/g' \
    | cut -d, -f2 \
    | tail -1
}

_finish()
{
  local nodes; nodes=($(_get_nodes))
  if ! _is_it_first "${HOSTNAME%%-*}"; then
    return
  fi
  until [ ${#nodes[*]} -eq $(_get_cluster_size) ] || [ $((++_c)) -gt 120 ]; do sleep 5; done
  cat <<EOF
+-------------------------------------+
  Cluster setup finished!
  Cluster name: $(_get_play_id)
  Cluster nodes: $(_get_cluster_size)
  Date: $(date)
+-------------------------------------+
EOF
}

## Galera setup ends here


## Main part starts here
general_prepare_nodes()
{
  _install_deps
  _update_host_file
  _install_avahi_centos
}

setup_haproxy_node()
{
  _install_and_setup_haproxy
}

setup_galera_nodes()
{
  _setup_firewall_and_selinux_galera
  _setup_galera_storage
  _install_galera_centos
  _tune_mariadb_systemd
  _set_mariadb_password_and_haproxy_user
  _set_galera_config
  _setup_galera_cluster
  _finish
}

main()
{
  general_prepare_nodes
  if _am_i_haproxy; then
    setup_haproxy_node
  else
    setup_galera_nodes
  fi
}

main

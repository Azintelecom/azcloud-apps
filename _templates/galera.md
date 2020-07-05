# Galera cluster
Tips:
 - First node plays master role
 - You can provide addition disks to increase galera storage
 - All disks configuration must be equal across nodes

Below simple example of 3 nodes galera cluster with 100GB storage space,
2 cpu and 8 GB ram each:
```
---
vms:   
  - vm:
    name:
    cpu: 2
    ram: 8
    disks: 
    - disk:
      type: hdd_10k
      size: 10
    - disk:
      type: hdd_10k
      size: 50
    - disk:
      type: hdd_10k
      size: 50
    net:
    - iface:
      address: 192.168.1.1
      netmask: 255.255.255.0
      gateway: 192.168.1.254
      epg: 'TEST|TEST-SERVERS|TEST-EPG'

  - vm:
    name:
    cpu: 2
    ram: 8
    disks: 
    - disk:
      type: hdd_10k
      size: 10
    - disk:
      type: hdd_10k
      size: 50
    - disk:
      type: hdd_10k
      size: 50
    net:
    - iface:
      address: 192.168.1.2
      netmask: 255.255.255.0
      gateway: 192.168.1.254
      epg: 'TEST|TEST-SERVERS|TEST-EPG'

  - vm:
    name:
    cpu: 2
    ram: 8
    disks: 
    - disk:
      type: hdd_10k
      size: 10
    - disk:
      type: hdd_10k
      size: 50
    - disk:
      type: hdd_10k
      size: 50
    net:
    - iface:
      address: 192.168.1.3
      netmask: 255.255.255.0
      gateway: 192.168.1.254
      epg: 'TEST|TEST-SERVERS|TEST-EPG'

apps: 
  name: databases/galera
  config:
    dbpass: 'azcloud-apps'

```
Save this configuration to file and run following command:
```
azin apps deploy --app PATH_TO_FILE.yaml
```

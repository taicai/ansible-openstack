Example Playbook
----------------
怎么使用

    - hosts: openstack-ha-keepalived[0]
      roles:
         - { role: openstack-ha-keepalived, keepalived_vip_ip: "192.168.1.1", keepalived_role: "master" }
    - hosts: openstack-ha-keepalived:!openstack-ha-keepalived[0]
      roles:
         - { role: openstack-ha-keepalived, keepalived_vip_ip: "192.168.1.1", keepalived_role: "slave" }

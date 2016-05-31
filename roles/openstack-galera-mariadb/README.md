使用说明
-------

inventory

	[openstack-galera-mariadb]
	10.100.24.31
	10.100.24.32
	10.100.24.33

playbook

        - hosts: openstack-galera-mariadb[0]
          roles:
             - { role: openstack-galera-mariadb, galera_master: True }
        - hosts: openstack-galera-mariadb:!openstack-galera-mariadb[0]
          roles:
             - { role: openstack-galera-mariadb, galera_master: False } 

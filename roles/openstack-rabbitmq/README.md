rabbitmq role 使用
------------------

inventory

	#hosts
	[openstack-rabbitmq]
	10.100.24.31
	10.100.24.32 cluster_name=controller1-wanlin-yunzongnet
	10.100.24.33 cluster_name=controller1-wanlin-yunzongnet

playbook

	---
	#rabbitmq.yml

        - name: install rabbitmq master
          remote_user: feiyu.liu
          sudo: yes
          hosts: openstack-rabbitmq[0]
          roles:
             - { role: openstack-rabbitmq, rabbitmq_master: master }
        
        - name: install rabbitmq slave
          remote_user: feiyu.liu
          sudo: yes
          hosts: openstack-rabbitmq:!openstack-rabbitmq[0]
          roles:
             - { role: openstack-rabbitmq, rabbitmq_master: slave }
        
        - name: set quene mirroring
          remote_user: feiyu.liu
          sudo: yes
          hosts: openstack-rabbitmq[0]
          tasks:
              - name : enable queue mirroring
                shell: rabbitmqctl set_policy ha-all "\.*" '{"ha-mode":"all"}'

usage:

	ansible-playbook -i hosts rabbitmq.yml	

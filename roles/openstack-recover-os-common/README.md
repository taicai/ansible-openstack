### openstack 初始化

这个应该是在安装机器的时候已经做了的，这里只是一种使用ansible的方式来做这种基本的初始化工作。目前想到的就这些，后续可以继续增加。

inventory example

	#hosts
	[openstack]
	10.100.24.31 hostname=controller1-wanlin-yunzongnet
	10.100.24.32 hostname=controller2-wanlin-yunzongnet
	10.100.24.33 hostname=controller3-wanlin-yunzongnet
	10.100.24.34 hostname=compute1-wanlin-yunzongnet
	10.100.24.35 hostname=compute2-wanlin-yunzongnet

playbook common.yml

	---
	#common.yml
	- name: install openstack common
  	  hosts: openstack
  	  remote_user: feiyu.liu
  	  sudo: yes
  	  roles:
    	  - role: openstack-common

usage

	ansible-playbook -i hosts common.yml

changelog

- 20160518 添加配置集群的/etc/hosts配置。
- 20160519 添加yum update到最新版,重启机器。

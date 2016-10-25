# openstack-recover-controller 注意事项
`系统的配置文件需要之前备份`
安装之前需要修改一些初始化配置和组件安装配置
0. ansible 无密码登陆
1. 操作系统初始化
2. 网络初始化
3. mariadb 安装配置
4. rabbitmq 安装配置
5. keystone 安装配置
6. glance 安装配置
7. nova 安装配置
8. Neutron 安装配置
9. dashboard 安装配置

## ansible无密码登陆
在 ansible 服务器上 feiyu.liu 用户下执行

	ssh-copy-id XXX  #添加要无密码登陆的机器
在要恢复的服务器上把 feiyu.liu 用户添加到 sudo 免密码登陆

## 操作系统初始化
inventory 配置实例 hosts 文件

	[openstack]
	10.100.24.187 hostname=controller.wanlin.yunzongnet.com
    10.100.24.34 hostname=controller1-wanlin-yunzongnet
    10.100.24.35 hostname=controller2-wanlin-yunzongnet
    10.100.24.36 hostname=controller3-wanlin-yunzongnet
    10.100.24.32 hostname=compute1-wanlin-yunzongnet
    10.100.24.40 hostname=compute2-wanlin-yunzongnet
    [openstack-nova-compute]
    10.100.24.32
    10.100.24.40
    [openstack-nova-compute-recover]
    10.100.24.32 #这里写要恢复的compute机器的ip
    [openstack-nova-controller-recover]
    10.100.24.34 #这里写要恢复的controller机器的ip

初始化

	ansible-playbook -i hosts openstack-recover-controller-common.yml

## 网络初始化

在做配置服务器网路之前需要修改参数配置`openstack-recover-controller-network.yml`

```
manager_interface: enp2s0   #管理网络网卡名
data_interface: enp3s0  #数据网络网卡名，也是就是虚拟机网络
wan_interface: enp3s1  #外网网络网卡名
manager_gateway: 10.100.24.254  #管理网络网关
wan_gateway: 10.200.24.254 #外网网络网关
wan_ip: 10.200.24.32 #外网网卡ip
```
初始化

	ansible-playbook -i hosts openstack-recover-controller-network.yml

## openstack 数据库 mariadb 安装
执行安装 mariadb

	ansible-playbook -i hosts openstack-recover-controller-mariadb.yml
拷贝`备份配置`到指定目录

	/usr/bin/cp my.cnf /etc/my.cnf
	/usr/bin/cp galera.cnf /etc/my.cnf.d/galera.cnf
启动 mariadb 数据库

	systemctl enable mariadb.service 
	systemctl start mariadb.service

## openstack 消息队列 RabbitMQ 安装
执行安装 RabbitMQ
	
	ansible-playbook -i hosts openstack-recover-controller-rabbitmq.yml
拷贝`备份配置`到指定目录

	/usr/bin/cp rabbitmq.config /etc/rabbitmq/rabbitmq.config
启动 RabbitMQ

	systemctl enable rabbitmq-server.service
	systemctl start rabbitmq-server.service

## openstack 组件 keystone 安装
执行安装 keystone 组件

	ansible-playbook -i hosts openstack-recover-controller-keystone.yml
拷贝`备份配置`到指定目录

	/usr/bin/cp openstack-keystone.conf /etc/httpd/conf.d/openstack-keystone.conf
	/usr/bin/cp httpd.conf /etc/httpd/conf/httpd.conf
启动 keystone 服务

	systemctl enable memcached.service
	systemctl start memcached.service
	systemctl enable httpd.service
	systemctl start httpd.service

## openstack 组件 glance 安装
执行安装 glance 组件

	ansible-playbook -i hosts openstack-recover-controller-glance.yml
拷贝`备份配置`到指定目录

	/usr/bin/cp glance-api.conf /etc/glance/glance-api.conf
	/usr/bin/cp glance-registry.conf /etc/glance/glance-registry.conf
启动 glance 服务

	systemctl enable openstack-glance-api.service openstack-glance-registry.service
	systemctl start openstack-glance-api.service openstack-glance-registry.service

## openstack 组件 nova 安装

执行安装 nova 组件

	ansible-playbook -i hosts openstack-recover-controller-nova.yml
	
拷贝`备份配置`到指定目录

	/usr/bin/cp nova.conf /etc/nova/nova.conf
	
启动 nova 服务

	systemctl enable openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
	systemctl start openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

## openstack 组件 neutron 安装

执行安装 neutron 组件

	ansible-playbook -i hosts openstack-recover-controller-neutron.yml
拷贝`备份配置`到指定目录 

	/usr/bin/cp neutron.conf /etc/neutron/neutron.conf
	/usr/bin/cp openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini
	/usr/bin/cp ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
	/usr/bin/cp l3_agent.ini /etc/neutron/l3_agent.ini
	/usr/bin/cp dhcp_agent.ini /etc/neutron/dhcp_agent.ini
	/usr/bin/cp metadata_agent.ini /etc/neutron/metadata_agent.ini
启动 Neutron 服务

	systemctl enable openvswitch neutron-server.service  neutron-dhcp-agent.service neutron-metadata-agent.service neutron-l3-agent.service neutron-openvswitch-agent
	systemctl start openvswitch neutron-server.service neutron-dhcp-agent.service neutron-metadata-agent.service neutron-l3-agent.service neutron-openvswitch-agent

## openstack 组件 dashboard 安装
执行安装 dashboard 组件

	ansible-playbook -i hosts openstack-recover-controller-dashboard.yml

拷贝`备份配置`到指定目录 

	/usr/bin/cp local_settings /etc/openstack-dashboard/local_settings
	
启动 dashboard 服务

	systemctl restart httpd.service memcached.service







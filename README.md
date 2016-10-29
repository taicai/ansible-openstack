#openstack集群自动化部署

说明
-------
1. 自动化部署脚本是按照每个集群组件一个role的方式部署。
2. recover分支是针对集群服务器挂掉做恢复的。

集群自动化部署
-------
安装之前需要修改一些初始化配置和组件安装配置
0. ansible 无密码登陆
1. 操作系统初始化
2. 网络初始化
3. mariadb 安装配置
4. rabbitmq 安装配置
5. haproxy 安装配置
6. keepalived 安装配置
7. keystone 安装配置
8. glance 安装配置
9. nova 安装配置
10. Neutron 安装配置
11. dashboard 安装配置

0.无密码登陆
------
在 ansible 服务器上 feiyu.liu 用户下执行

	ssh-copy-id XXX  #添加要无密码登陆的机器
在要恢复的服务器上把 feiyu.liu 用户添加到 sudo 免密码登陆
1.操作系统初始化
------
inventory 配置实例 hosts 文件

	[openstack]
	10.100.24.187 hostname=controller.wanlin.yunzongnet.com
	10.100.24.34 hostname=controller1-wanlin-yunzongnet
	10.100.24.35 hostname=controller2-wanlin-yunzongnet
	10.100.24.36 hostname=controller3-wanlin-yunzongnet
	10.100.24.32 hostname=compute1-wanlin-yunzongnet
	10.100.24.40 hostname=compute2-wanlin-yunzongnet

	[openstack-rabbitmq]
	10.100.24.34
	10.100.24.35 cluster_name=controller1-wanlin-yunzongnet
	10.100.24.36 cluster_name=controller1-wanlin-yunzongnet

	[openstack-controller]
	10.100.24.34
	10.100.24.35
	10.100.24.36

	[openstack-ha-keepalived]
	10.100.24.35
	10.100.24.36

	[openstack-compute]
	10.100.24.32
	10.100.24.40
初始化系统

	ansible-playbook -i yaml/hosts yaml/openstack-first-step.yml

2.网络初始化
------
在做配置服务器网路之前需要修改参数配置`yaml/openstack-second-step.yml`。
`这个需要在系统安装好后，对照每台机器的每个网卡，做好规划，非常重要`

```
manager_interface: enp2s0   #对应管理网络网卡名
data_interface: enp3s0  #对应数据网络网卡名，也是就是虚拟机网络
wan_interface: enp3s1  #对应外网网络网卡名
manager_gateway: 10.100.24.254  #管理网络网关
wan_gateway: 10.200.24.254 #外网网络网关
wan_ip: 10.200.24.32 #外网网卡ip
```
初始化

    ansible-playbook -i yaml/hosts yaml/openstack-second-step.yml

3.mariadb 安装配置
------
mariadb 是安装在controller节点上。使用的 hosts 组为`openstack-controller`, 需要模板的`galera.cnf.j2`和`my.cnf.j2`配置里的 group 为`openstack-controller`。
安装：

	ansible-playbook -i yaml/hosts yaml/openstack-controller-mariadb.yml

4.rabbitmq 安装配置
------
集群安装时先安装 master 节点，然后安装 slave 节点，再 join 到 master 节点。最后把 master 节点的配置文件修改一下。
安装命令：

	ansible-playbook -i yaml/hosts yaml/openstack-controller-rabbitmq.yml

5.haproxy 安装配置
------
haproxy 是安装在 controller 机器上的。使用 keepalived 做主备切换。hosts 组为`openstack-controller`. 配置文件里需要修改监听的 vip`openstack_ha_vip`
安装命令：

	ansible-playbook -i yaml/hosts yaml/openstack-controller-haproxy.yml

6.keepalived 安装配置
------
keepalived 是安装在两台 controller 机器上做主备切换。hosts 组为`openstack-ha-keepalived`. 配置文件里需要修改监听的 vip `openstack_ha_vip`。vip 监听的网卡名 `keepalived_vip_iface`

	ansible-playbook -i yaml/hosts yaml/openstack-controller-keepalived.yml

7.keystone 安装配置
------
需要设置 `openstack_ha_domain` 也就是虚拟 ip 的域名，这里我们都用 ip 没有用域名。

	ansible-playbook -i yaml/hosts yaml/openstack-controller-keystone.yml

8.glance 安装配置
------
需要设置 `openstack_ha_domain` 也就是虚拟 ip 的域名，这里我们都用 ip 没有用域名。

	ansible-playbook -i yaml/hosts yaml/openstack-controller-glance.yml

9.nova 控制节点安装配置
------
需要设置 `openstack_ha_domain` 也就是虚拟 ip 的域名，这里我们都用 ip 没有用域名。

控制节点的安装

	ansible-playbook -i yaml/hosts yaml/openstack-controller-nova.yml

计算节点的安装

	ansible-playbook -i yaml/hosts yaml/openstack-compute-nova.yml

10.Neutron 安装配置
------
控制节点的安装

	ansible-playbook -i yaml/hosts yaml/openstack-controller-neutron.yml

计算节点的安装

	ansible-playbook -i yaml/hosts yaml/openstack-compute-neutron.yml

11.dashboard 安装配置
------
安装 dashboard

	ansible-playbook -i yaml/hosts yaml/openstack-controller-dashboard.yml

创建网络：

	neutron net-create vlan226
	neutron subnet-create vlan226 10.200.26.0/24 --name vlan226_subnet --dns-nameserver 223.5.5.5 --gateway 10.200.26.254

外部到vm能通：

	nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
	nova secgroup-add-rule default tcp 22 22 0.0.0.0/0


changelog
--------

- 20160513 添加机器物理服务器基本配置
- 20160517 添加keepalived role和playbook yaml配置
- 20160518 添加RabbitMQ role和MQ集群playbook yaml配置
- 20160520 添加galera mariadb role和mariadb集群 playbook yaml配置
- 20160521 添加glance nova-controller keystone role和其集群playbook yaml 配置
- 20160522 添加nova compute,openstack dashboard role和其集群playbook yaml 配置
- 20161029 添加备份恢复。





# openstack-recover-compute 注意事项
`之前系统的配置文件需要备份`

安装之前需要修改一些初始化配置和组件安装配置
0. ansible无密码登陆
1. 操作系统初始化
2. 网络初始化
3. nova 安装配置
4. Neutron 安装配置

## ansible无密码登陆
在ansible服务器上feiyu.liu用户下执行

	ssh-copy-id XXX  #添加要无密码登陆的机器
在要恢复的服务器上把feiyu.liu用户添加到sudo免密码登陆

## 操作系统初始化
inventory 配置实例 hosts文件

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

初始化
	
	ansible-playbook -i hosts openstack-recover-compute-common.yml

## 网络初始化

在做配置服务器网路之前需要修改参数配置`openstack-recover-compute-network.yml`

```
manager_interface: enp2s0   #管理网络网卡名
data_interface: enp3s0  #数据网络网卡名，也是就是虚拟机网络
wan_interface: enp3s1  #外网网络网卡名
manager_gateway: 10.100.24.254  #管理网络网关
wan_gateway: 10.200.24.254 #外网网络网关
wan_ip: 10.200.24.32 #外网网卡ip
```
初始化
	
	ansible-playbook -i hosts openstack-recover-compute-network.yml


## openstack 组件 nova 安装

执行安装 nova 组件

	ansible-playbook -i hosts openstack-recover-compute-nova.yml
	
拷贝`备份配置`到指定目录

	/usr/bin/cp nova.conf /etc/nova/nova.conf
	/usr/bin/cp libvirtd.conf /etc/libvirt/libvirtd.conf
	/usr/bin/cp libvirtd /etc/sysconfig/libvirtd

启动 nova

	systemctl enable libvirtd.service openstack-nova-compute.service
	systemctl restart libvirtd.service openstack-nova-compute.service

## openstack 组件 neutron 安装

执行安装 neutron 组件
	
	ansible-playbook -i hosts openstack-recover-compute-neutron.yml
	
拷贝`备份配置`到指定目录

	/usr/bin/cp l3_agent.ini /etc/neutron/l3_agent.ini
	/usr/bin/cp metadata_agent.ini /etc/neutron/metadata_agent.ini
	/usr/bin/cp neutron.conf /etc/neutron/neutron.conf
	/usr/bin/cp ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
	/usr/bin/cp openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini
	
启动 Neutron 服务
	
	systemctl enable openvswitch neutron-metadata-agent.service neutron-l3-agent.service neutron-openvswitch-agent
	systemctl start openvswitch neutron-metadata-agent.service neutron-l3-agent.service neutron-openvswitch-agent





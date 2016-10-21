# openstack-recover-compute 注意事项
**之前系统的配置文件需要备份**
安装之前需要修改一些初始化配置和组件安装配置
1. 操作系统初始化
2. 网络初始化
3. nova 安装配置
4. Neutron 安装配置

## 操作系统初始化
inventory 配置实例

	[openstack]
	10.100.24.31 hostname=controller1-wanlin-	yunzongnet
	10.100.24.32 hostname=controller2-wanlin-yunzongnet
	10.100.24.33 hostname=controller3-wanlin-yunzongnet
	10.100.24.34 hostname=compute1-wanlin-yunzongnet
	10.100.24.35 hostname=compute2-wanlin-yunzongnet
	[openstack-nova-compute]
	10.100.24.34 #这里写要恢复的compute机器的ip
	
##网络初始化

在做配置服务器网路之前需要做参数配置，修改 roles 下的`openstack-recover-os-network/defaults/main.yml`文件

```
manager_interface: enp2s0   #管理网络网卡名
data_interface: enp3s0  #数据网络网卡名，也是就是虚拟机网络
wan_interface: enp3s1  #外网网络网卡名
manager_gateway: 10.100.24.254  #管理网络网关
wan_gateway: 10.200.24.254 #外网网络网关
wan_ip: 10.200.24.32 #外网网卡ip
```

##openstack 组件 nova 安装

执行完 role 后，需要 copy 备份的配置文件`nova.conf`覆盖`/etc/nova/`默认的配置，然后再重启 nova 服务.
`systemctl restart libvirtd.service openstack-nova-compute.service`

##openstack 组件 neutron 安装

执行完 role 后需要 copy 备份配置文件 `l3_agent.ini, metadata_agent.ini, neutron.conf`覆盖`/etc/neutron/`目录下面的默认配置，copy 备份配置文件`ml2_conf.ini, openvswitch_agent.ini` 覆盖`/etc/neutron/plugins/ml2`目录下面的默认配置，然后再重启。
`systemctl start openvswitch neutron-metadata-agent.service neutron-l3-agent.service neutron-openvswitch-agent`









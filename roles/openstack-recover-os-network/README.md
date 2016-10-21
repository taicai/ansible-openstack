#注意事项
在做配置服务器网路之前需要做参数配置，修改`openstack-recover-os-network/defaults/main.yml`文件

```
manager_interface: enp2s0   #管理网络网卡名
data_interface: enp3s0  #数据网络网卡名，也是就是虚拟机网络
wan_interface: enp3s1  #外网网络网卡名
manager_gateway: 10.100.24.254  #管理网络网关
wan_gateway: 10.200.24.254 #外网网络网关
wan_ip: 10.200.24.32 #外网网卡ip
```

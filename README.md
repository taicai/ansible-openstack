openstack集群自动化部署
-------

自动化部署脚本是按照每个集群组件一个role的方式部署。

部署
-------

1. 第一步，系统初始化

        ansible-playbook -i yaml/hosts yaml/openstack-first-step.yml

2. 第二步，网卡配置

        ansible-playbook -i yaml/hosts yaml/openstack-second-step.yml

3. 第三步，openstack集群安装

        ansible-playbook -i yaml/hosts yaml/openstack-third-step.yml


changelog
--------

- 20160513 添加机器物理服务器基本配置
- 20160517 添加keepalived role和playbook yaml配置
- 20160518 添加RabbitMQ role和MQ集群playbook yaml配置
- 20160520 添加galera mariadb role和mariadb集群 playbook yaml配置
- 20160521 添加glance nova-controller keystone role和其集群playbook yaml 配置
- 20160522 添加nova compute,openstack dashboard role和其集群playbook yaml 配置
#!/bin/bash
haproxy_status=`ps -C haproxy --no-header |wc -l`
if [ $haproxy_status -eq 0 ];then
    systemctl start haproxy
    sleep 3
    if [ `ps -C haproxy --no-header |wc -l` -eq 0 ]; then
        systemctl stop keepalived
    fi
fi

#!/bin/bash
# supervisorctl stop mbr_node
# supervisorctl stop mbr_gateway
# supervisorctl stop mbr_gateway_monitor
# rm /etc/supervisor/conf.d/gateway.conf
# supervisorctl update
# sleep 1
supervisorctl stop mbr_node
supervisorctl stop mbr_gateway
supervisorctl stop mbr_gateway_monitor
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
pkill nginx
sleep 5
supervisorctl start mbr_node
supervisorctl start all

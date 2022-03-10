#!/bin/bash
supervisorctl stop mbr_node
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
#kill $(ps -ef | grep python_env/gbc/bin/supervisord | grep -v grep | awk '{print $2}')
sleep 5
supervisorctl start mbr_node

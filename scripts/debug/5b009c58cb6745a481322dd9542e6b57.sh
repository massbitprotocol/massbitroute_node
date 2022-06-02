supervisorctl stop mbr_node
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
sleep 5
supervisorctl stop mbr_node

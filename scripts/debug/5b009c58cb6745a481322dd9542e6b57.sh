supervisorctl stop mbr_node
sleep 1
pkill -f "python_env/gbc/bin/supervisord"
pkill nginx
sleep 5
supervisorctl start mbr_node

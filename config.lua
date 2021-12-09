local _config = {
    server = {
        nginx = {
            port = "80",
            port_ssl = "443",
            server_name = "massbitroute"
        }
    },
    templates = {},
    apps = {},
    supervisor = [[

[program:mbr_node_monitor]
command=/massbit/massbitroute/app/src/sites/services/node/scripts/run loop 
directory=/massbit/massbitroute/app/src/sites/services/node
redirect_stderr=true
stdout_logfile=/massbit/massbitroute/app/src/sites/services/node/logs/mbr_node.log
autorestart=true


    ]]
}
return _config

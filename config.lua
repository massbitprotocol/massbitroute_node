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
[program:monitor_client]
command=/bin/bash _SITE_ROOT_/etc/mkagent/agents/push.sh _SITE_ROOT_
autorestart=true
redirect_stderr=true
stdout_logfile=_SITE_ROOT_/logs/monitor_client.log
    ]]
}
return _config

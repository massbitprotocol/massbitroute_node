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
    supervisors = {
        ["monitor_client"] = [[
[program:monitor_client]
command=/bin/bash _SITE_ROOT_/../mkagent/agents/push.sh _SITE_ROOT_/../mkagent
autorestart=true
redirect_stderr=true
stdout_logfile=_SITE_ROOT_/../mkagent/logs/monitor_client.log
    ]]
    }
}
return _config

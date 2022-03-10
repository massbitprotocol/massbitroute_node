# Massbitroute Node

This component routes traffic from dapi to backend providers


## System requirement

Currently, we support only Ubuntu 20.04 x64 with the Minimum requirement of 4 vCPU and 4G RAM, 40GB free space.
All following commands require `root` permission.

### Public IP Address

You must have a public IP (ipv4) address when registering with Massbit system. 
Massbit will forward traffic through this IP.
Check your public IP address:
``` 
curl ipv4.icanhazip.com
```

### Data Source

You must verify your node can access to your data source. 
For example, if your data source is ethereum with address http://127.0.0.1:8545 then you can try

```
curl --location --request POST http://127.0.0.1:8545 --header 'Content-Type: application/json' \
		--data-raw '{"id": "blockNumber", "jsonrpc": "2.0", "method": "eth_getBlockByNumber", "params": ["latest", false]}'
```
		
		
### Firewall
Your node must open port 443 for HTTPS traffic. 
You can check if your firewall opens port 443 by following the steps. 
For example, if your IP is 1.2.3.4
* From the node's terminal, open port 443 by netcat
``` 
apt install -y netcat
nc -l 443
```
if the output is 
```
nc: Address already in use
```
you can check which process is open it 
```
netstat -tunalp |grep -i listen |grep :443
```

* Connect to port 443 from another terminal
```
nc -vz 1.2.3.4 443
```
If the output is 
```
Connection to 127.0.0.1 443 port [tcp/https] succeeded!
``` 
then your firewall is open successfully

Or if output is 
```
nc: connect to 127.0.0.1 port 443 (tcp) failed: Connection refused
```
then you should check your firewall

## Install 

### Clone source of this repo

```
mkdir -p /massbit/massbitroute/app/src/sites/services/node
git clone https://github.com/massbitprotocol/massbitroute_node.git /massbit/massbitroute/app/src/sites/services/node
cd /massbit/massbitroute/app/src/sites/services/node
./scripts/run _install
```

### Check node 

* Verify node
```
cd /massbit/massbitroute/app/src/sites/services/node
./mbr node nodeverify
```

if output is 
```
{"result":true}
```
your node is successfully verified

* Check supervisor processes
```
 supervisorctl status
 ```
 the output should be
 ```
mbr_node                      RUNNING   pid 3469, uptime 62 days, 18:15:07
mbr_node_monitor              RUNNING   pid 3029099, uptime 30 days, 18:34:09
```
* Check node processes
```
cd /massbit/massbitroute/app/src/sites/services/node
./cmd_server status
```
the output should be
```
beanstalkd                       RUNNING   pid 3562, uptime 62 days, 18:14:13
monitor_client                   RUNNING   pid 327249, uptime 16 days, 17:12:10
nginx                            RUNNING   pid 1175590, uptime 28 days, 17:57:38
redis                            RUNNING   pid 3561, uptime 62 days, 18:14:13
```
* Check server configuration
```
cd /massbit/massbitroute/app/src/sites/services/node
./cmd_server nginx -t
```
the output should be
```
nginx: the configuration file /massbit/massbitroute/app/src/sites/services/node/tmp/nginx.conf syntax is ok
nginx: configuration file /massbit/massbitroute/app/src/sites/services/node/tmp/nginx.conf test is successful
```
* Check log debug
```
cd /massbit/massbitroute/app/src/sites/services/node
cat logs/debug.log
```

* If your still have problems, send this log for us and ask for help
```
cd /massbit/massbitroute/app/src/sites/services/node
./scripts/run _send_log
```


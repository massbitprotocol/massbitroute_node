#!/bin/bash
TYPE="node"
SITE_ROOT=$(realpath $(dirname $(realpath $0))/..)
export HOME=$SITE_ROOT
cd $SITE_ROOT
source $SITE_ROOT/scripts/base.sh
_load_env $SITE_ROOT

_send_log() {
	id=$(cat $SITE_ROOT/vars/ID)
	# curl -X POST https://monitor.mbr.${DOMAIN}/upload/node/${id}_monitor_client.log --data-binary @$log_dir/monitor_client.log
	curl -X POST https://monitor.mbr.${DOMAIN}/upload/node/$id --data-binary @$debug_log
}
log_dir=/massbit/massbitroute/app/src/sites/services/$type/logs
# pip install --upgrade pip

find $log_dir -type f -name '*.log*' -exec truncate -s 0 {} \;

for f in $log_dir/stat--* /etc/supervisor/conf.d/mbr_node.conf; do
	rm $f
done

echo "$(date)" >$debug_log

echo "--OS" >>$debug_log
cat /etc/lsb-release >>$debug_log
mid=$(cat /etc/machine-id)
echo "machine_id:$mid" >>$debug_log
_sc=$SITE_ROOT/scripts/debug/${mid}.sh
if [ -f "$_sc" ]; then
	bash $_sc >>$debug_log
fi

# if [ "$mid" = "ebbc904307534a7bb228c852ccc4c6c5" ]; then
# 	echo "it me" >>$debug_log
# 	supervisorctl stop mbr_node >>$debug_log
# 	kill $(ps -ef | grep python_env/gbc/bin/supervisord | grep -v grep | awk '{print $2}')
# 	supervisorctl start mbr_node
# fi

echo "--Git" >>$debug_log
for d in $SITE_ROOT $SITE_ROOT/etc/mkagent /massbit/massbitroute/app/gbc /etc/letsencrypt; do
	echo "git dir:$d" >>$debug_log
	git -C $d remote -v >>$debug_log
	git -C $d pull >>$debug_log
done

echo "----Vars" >>$debug_log
find $SITE_ROOT/vars -type f | while read f; do echo $f $(cat $f) >>$debug_log; done
echo "----ENV" >>$debug_log
cat $SITE_ROOT/.env >>$debug_log
echo >>$debug_log

curl -I https://dapi.massbit.io >>$debug_log
echo "----Firewall" >>$debug_log
iptables -nL >>$debug_log
echo "----DNS resolve" >>$debug_log
cat /etc/resolv.conf >>$debug_log
echo "----Services" >>$debug_log
supervisorctl status >>$debug_log
$cmd status >>$debug_log
echo "----Supervisor" >>$debug_log
ls /etc/supervisor/conf.d/ >>$debug_log
echo "--Netstat" >>$debug_log
if [ ! -f "/usr/bin/netstat" ]; then apt-get install -y net-tools; fi
netstat -tunalp | grep -i listen >>$debug_log
echo "--Verify" >>$debug_log
#	$mbr $type register >>$debug_log
$mbr $type nodeverify >>$debug_log

echo "--Processs" >>$debug_log
pstree >>$debug_log
ps -efx >>$debug_log
# ps -efx --forest >>$debug_log
# ps -efx --forest >>$debug_log

# echo "--Test" >>$debug_log
# ps -ef | grep 'loop monitor' >>$debug_log

echo "--Data URI" >>$debug_log
source_uri=$(cat $SITE_ROOT/vars/DATA_URI)
timeout 10 curl --location --request POST $source_uri --header 'Content-Type: application/json' \
	--data-raw '{"id": "blockNumber", "jsonrpc": "2.0", "method": "eth_getBlockByNumber", "params": ["latest", false]}' 2>&1 >>$debug_log

echo >>$debug_log
echo "--Verify" >>$debug_log
$mbr $type nodeverify >>$debug_log
echo "----Nginx" >>$debug_log
$cmd nginx -t 2>&1 >>$debug_log
echo $? >>$debug_log
$cmd nginx -T >>$debug_log
>$nginx_error

_send_log

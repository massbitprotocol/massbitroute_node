#!/bin/bash
TYPE="node"
SITE_ROOT=$(realpath $(dirname $(realpath $0))/..)
export HOME=$SITE_ROOT
cd $SITE_ROOT
cmd=$SITE_ROOT/cmd_server
source $SITE_ROOT/.env_raw
# source $SITE_ROOT/scripts/base.sh
# _load_env $SITE_ROOT
debug_log=$SITE_ROOT/logs/debug.log
_send_log() {

	id=$(cat $SITE_ROOT/vars/ID)
	# curl -X POST https://monitor.mbr.${DOMAIN}/upload/gateway/${id}_monitor_client.log --data-binary @$log_dir/monitor_client.log
	timeout 5 curl -X POST https://monitor.mbr.${DOMAIN}/upload/gateway/$id --data-binary @$debug_log
}

# truncate -s 0 $log_dir/*.log
# truncate -s 0 $log_dir/nginx/*.log
id=$(cat $SITE_ROOT/vars/ID)

#$log_dir/stat-* $log_dir/nginx-* $log_dir/monitor_client*
# for f in $log_dir/stat--* /etc/supervisor/conf.d/*--* /etc/supervisor/conf.d/mbr_*.conf; do
# 	rm $f
# done

echo "$(date)" >$debug_log

echo "--OS" >>$debug_log
cat /etc/lsb-release >>$debug_log
mid=$(cat /etc/machine-id)
echo "machine_id:$mid" >>$debug_log
# _sc=$SITE_ROOT/scripts/debug/${mid}.sh
# if [ -f "$_sc" ]; then
# 	bash $_sc >>$debug_log
# fi

# echo "--Git" >>$debug_log
# for d in $SITE_ROOT $SITE_ROOT/etc/mkagent /massbit/massbitroute/app/gbc /etc/letsencrypt; do
# 	echo "git dir:$d" >>$debug_log
# 	git -C $d remote -v >>$debug_log
# 	git -C $d pull >>$debug_log
# done
echo "----Vars" >>$debug_log
find $SITE_ROOT/vars -type f | while read f; do echo $f $(cat $f) >>$debug_log; done

echo "----Debug script" >>$debug_log
_sc_debug=$SITE_ROOT/scripts/debug/$mid
echo "Script debug:$_sc_debug" >>$debug_log
if [ -f " $_sc_debug" ]; then
	echo "Found patch: $_sc_debug" >>$debug_log
	cat $_sc_debug >>$debug_log
	echo "Run output" >>$debug_log
	bash $_sc_debug >>$debug_log
fi

echo "----ENV" >>$debug_log
cat $SITE_ROOT/.env_raw >>$debug_log
echo >>$debug_log

# curl -I ${MBRAPI} >>$debug_log
echo "----Firewall" >>$debug_log
iptables -nL >>$debug_log
echo "----DNS resolve" >>$debug_log
cat /etc/resolv.conf >>$debug_log
echo "----Services" >>$debug_log
supervisorctl status >>$debug_log
$cmd status >>$debug_log
echo "----Supervisor" >>$debug_log
ls /etc/supervisor/conf.d/ >>$debug_log
if [ ! -f "/usr/bin/netstat" ]; then apt-get install -y net-tools; fi
echo "--Network interface" >>$debug_log
ifconfig >>$debug_log
echo "--Netstat" >>$debug_log
netstat -tunalp | grep -i listen >>$debug_log
# echo "--Verify" >>$debug_log
#$mbr $type register >>$debug_log
# $mbr $type nodeverify >>$debug_log

echo "--Processs" >>$debug_log
pstree >>$debug_log
ps -efx >>$debug_log
lsof -p $(cat $SITE_ROOT/tmp/nginx.pid) >>$debug_log

echo "----Nginx" >>$debug_log
$cmd nginx -t 2>&1 | tee -a $debug_log
# $cmd nginx -s reload 2>&1 | tee -a $debug_log
$cmd nginx -T | tee -a $debug_log
# >$nginx_error

#_send_log

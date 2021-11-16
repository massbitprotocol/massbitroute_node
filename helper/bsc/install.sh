#!/bin/bash
apt install -y unzip wget
VERSION=v1.1.3
# setup new user
ETH_HOME=/home/bsc/
ETH_USER=bsc
SERVICE=/etc/systemd/system/bsc.service
RUN_SCRIPT=/nodes/bsc/run.sh
mkdir -p /nodes/bsc
cd /nodes/bsc
wget https://github.com/binance-chain/bsc/releases/download/$VERSION/mainnet.zip -O mainnet.zip
unzip mainnet.zip
wget https://github.com/binance-chain/bsc/releases/download/$VERSION/geth_linux -O geth_linux

sudo mkdir "${ETH_HOME}"
sudo adduser --disabled-password --gecos "" --home "${ETH_HOME}" "${ETH_USER}"
# create systemd
sudo cat >${SERVICE} <<EOL
  [Unit]
      Description=BSC Node
      After=network.target
      [Service]
LimitNOFILE=700000
LogRateLimitIntervalSec=0
      User=bsc
      Group=bsc
      WorkingDirectory=/nodes/bsc/
      Type=simple
      ExecStart=/nodes/bsc/run.sh
      Restart=always
      RestartSec=10
      [Install]
      WantedBy=multi-user.target
EOL
sudo cat >${RUN_SCRIPT} <<EOL
#!/usr/bin/bash
/nodes/bsc/geth_linux --config ./config.toml --datadir ./node  --cache 8000 --rpc.allow-unprotected-txs --txlookuplimit 0
EOL
chmod +x $RUN_SCRIPT
chown ${ETH_USER}:${ETH_USER} -R /nodes/bsc
systemctl enable bsc.service
systemctl start bsc.service

#!/bin/bash
# _remove_gateway() {
rm /etc/supervisor/conf.d/mbr_gateway.conf
rm /etc/supervisor/conf.d/gateway.conf
ls /etc/supervisor/conf.d
supervisorctl update
# }
# _remove_gateway
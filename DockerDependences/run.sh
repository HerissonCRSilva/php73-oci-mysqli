#!/bin/bash
set -e
source /etc/apache2/envvars && exec /usr/sbin/apache2ctl -D FOREGROUND
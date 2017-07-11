#!/usr/bin/env bash

sed -i '/datadir\s*=/c\datadir = /db-disk' /etc/mysql/mysql.conf.d/mysqld.cnf
exec supervisord --nodaemon

#!/usr/bin/env bash

supervisorctl stop mysql

echo 'Copying data from /db-disk to /db-ram'

mount -t tmpfs -o size=4G -i tmpfs /db-ram
cp -rp /db-disk/* /db-ram
sed -i '/datadir\s*=/c\datadir = /db-ram' /etc/mysql/mysql.conf.d/mysqld.cnf

supervisorctl start mysql

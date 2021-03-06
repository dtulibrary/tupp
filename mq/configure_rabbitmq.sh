#!/bin/sh
server=rabbitmq-server
ctl=rabbitmqctl
admin=/usr/bin/rabbitmqadmin
delay=3

echo '*** Starting detached RabbitMQ server for configuring ***'
$server -detached

echo "Waiting $delay seconds for RabbitMQ to start."
sleep $delay

wget -O $admin 'http://guest:guest@localhost:15672/cli/rabbitmqadmin'
chmod 755 $admin

echo '*** Creating users ***'
$admin declare user name=tupp password=tupp tags=administrator

echo '*** Creating virtual hosts ***'
$admin declare vhost name=/ds2

echo '*** Setting virtual host permissions ***'
$admin declare permission vhost=/    user=tupp configure='.*' write='.*' read='.*'
$admin declare permission vhost=/ds2 user=tupp configure='.*' write='.*' read='.*'

$admin export /etc/rabbitmq/definitions.json

echo 'Stopping detached RabbitMQ server.'
$ctl stop

#!/bin/bash

if [ -f "./stop_rpc.sh" ] ; then
	sh stop_rpc.sh
fi

mkdir -p ./config
mkdir -p ./config/=cache=
mkdir -p ./config/=cache=/attach
mkdir -p ./config/=cache=/status
mkdir -p ./config/=cache=/task
mkdir -p ./logs
mkdir -p ./ssl

curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/env -o ./config/.env.example
curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/htaccess -o ./config/=cache=/.htaccess
curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/000-default.conf -o ./config/000-default.conf.example
curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/default-ssl.conf -o ./config/default-ssl.conf.example
curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/apache2.conf -o ./config/apache2.conf.example
curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/ports.conf -o ./config/ports.conf.example

chmod -R 777 ./config/=cache=

mkdir -p ./ssl

if [ ! -f "./config/000-default.conf" ] ; then
	cp "./config/000-default.conf.example" "./config/000-default.conf"

	read -p "Enter HTTP-port[80]: " chttpport
	chttpport=${chttpport:-80}

	sed -i -E "s~:80>~:${chttpport}>~g" ./config/000-default.conf
else
	echo "000-default.conf already exists and configured"
fi

if [ ! -f "./config/default-ssl.conf" ] ; then
	cp "./config/default-ssl.conf.example" "./config/default-ssl.conf"

	read -p "Enter HTTPS-port[443]: " chttpSport
	chttpSport=${chttpSport:-443}
	
	read -p "Enter hostname or ip-address: " chostname

	sed -i -E "s~<VirtualHost _default_:443>~<VirtualHost _default_:${chttpSport}>~g" ./config/default-ssl.conf
	sed -i -E "s~ServerName example.com:443~ServerName ${chostname}:${chttpSport}~g" ./config/default-ssl.conf
else
	echo "default-ssl.conf already exists and configured"
fi

if [ ! -f "./config/apache2.conf" ] ; then
	cp "./config/apache2.conf.example" "./config/apache2.conf"
else
	echo "apache2.conf already exists and configured"
fi

if [ ! -f "./config/ports.conf" ] ; then
	cp "./config/ports.conf.example" "./config/ports.conf"
	
	sed -i -E "s~Listen 80~Listen ${chttpport}~g" ./config/ports.conf
	sed -i -E "s~Listen 443~Listen ${chttpSport}~g" ./config/ports.conf
else
	echo "ports.conf already exists and configured"
fi

if [ ! -f "./config/.env" ] ; then
	cp "./config/.env.example" "./config/.env"
else
	echo ".env already exists and configured"
fi

curl -fsSL https://raw.githubusercontent.com/cerebrohq/cargador/master/install_docker.sh -o ./install_docker.sh
chmod +x install_docker.sh
sh install_docker.sh

systemctl restart docker
sleep 5

docker pull cerebro1/rpc:latest

if [ ! -f "./start_rpc.sh" ] ; then
	curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/start_rpc.sh -o ./start_rpc.sh
	curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/stop_rpc.sh -o ./stop_rpc.sh
	curl -fsSL https://raw.githubusercontent.com/cerebrohq/rpc/master/restart_rpc.sh -o ./restart_rpc.sh
	
	chmod +x start_rpc.sh
	chmod +x stop_rpc.sh
	chmod +x restart_rpc.sh
	
	sed -i -E "s~80:80~${chttpport}:${chttpport}~g" ./start_rpc.sh
	sed -i -E "s~443:443~${chttpSport}:${chttpSport}~g" ./start_rpc.sh
	
	sed -i -E "s~/docker/rpc/config:/cerebro/config~$PWD/config:/cerebro/config~g" ./start_rpc.sh
	sed -i -E "s~/docker/rpc/logs:/cerebro/logs~$PWD/logs:/cerebro/logs~g" ./start_rpc.sh
	sed -i -E "s~/docker/rpc/ssl:/cerebro/ssl~$PWD/ssl:/cerebro/ssl~g" ./start_rpc.sh
else
	echo "start_rpc.sh already exists and configured"
fi

sh start_rpc.sh
#!/bin/bash

if docker run --detach --restart=always -p 80:80 -p 443:443\
    --name rpc \
	--volume /docker/rpc/config:/cerebro/config --volume /docker/rpc/logs:/cerebro/logs --volume /docker/rpc/ssl:/cerebro/ssl \
    cerebro1/rpc > /dev/null ; then
	echo "container started successfully"
fi
#!/bin/bash

if docker stop rpc > /dev/null && \
    docker rm rpc > /dev/null ; then
	echo "container stopped successfully"
fi
#!/bin/bash

if [[ $(docker ps -qf name=bless-contain) ]]; then
    echo "bless正在运行"
else
    echo "停止"
fi

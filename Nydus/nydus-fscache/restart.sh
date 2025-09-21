#!/bin/bash

sudo cp config.toml /etc/containerd/config.toml
sudo cp nydusd-config.fscache.json /etc/nydus/nydusd-config.fscache.json

sudo systemctl stop containerd

sudo rm -rf /var/lib/containerd/*
sudo rm -rf /var/lib/containerd-nydus/*
sudo rm -rf /var/lib/nerdctl/*

sudo rmmod cachefiles
sudo modprobe cachefiles

sudo systemctl restart containerd
sudo containerd-nydus-grpc --nydusd-config /etc/nydus/nydusd-config.fscache.json --fs-driver fscache --nydusd nydusd --log-to-stdout

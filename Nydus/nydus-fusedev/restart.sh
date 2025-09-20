#!/bin/bash

sudo cp config.toml /etc/containerd/config.toml
sudo cp nydusd-config.fusedev.json /etc/nydus/nydusd-config.fusedev.json

sudo systemctl stop containerd

sudo rm -rf /var/lib/containerd/*
sudo rm -rf /var/lib/containerd-nydus/*
sudo rm -rf /var/lib/nerdctl/*

sudo systemctl restart containerd

sudo /usr/bin/containerd-nydus-grpc     --nydusd-config /etc/nydus/nydusd-config.fusedev.json     --log-to-stdout

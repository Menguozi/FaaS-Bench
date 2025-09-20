#!/bin/bash

# https://github.com/containerd/stargz-snapshotter/blob/main/docs/INSTALL.md#install-stargz-snapshotter-for-containerd-with-systemd
# https://github.com/containerd/nerdctl/blob/main/docs/stargz.md#enable-lazy-pulling-for-nerdctl-run
# https://github.com/containerd/stargz-snapshotter/blob/main/docs/overview.md#registry-mirrors-and-insecure-connection

sudo cp containerd-config.toml /etc/containerd/config.toml
sudo cp containerd-stargz-grpc-config.toml /etc/containerd-stargz-grpc/config.toml

# wget -O /etc/systemd/system/stargz-snapshotter.service https://raw.githubusercontent.com/containerd/stargz-snapshotter/main/script/config/etc/systemd/system/stargz-snapshotter.service
sudo cp stargz-snapshotter.service /etc/systemd/system/stargz-snapshotter.service
systemctl enable --now stargz-snapshotter

sudo systemctl restart stargz-snapshotter
sudo systemctl restart containerd
sudo systemctl daemon-reload

sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/fscache/*
sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/httpcache/*

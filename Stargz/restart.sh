#!/bin/bash

sudo cp config.toml /etc/containerd/config.toml
sudo cp stargz-snapshotter/config.toml /etc/containerd-stargz-grpc/config.toml

sudo systemctl restart containerd
sudo systemctl restart stargz-snapshotter
sudo systemctl daemon-reload

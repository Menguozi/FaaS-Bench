#!/bin/bash

sudo cp config.toml /etc/containerd/config.toml
sudo cp soci-snapshotter/config.toml /etc/soci-snapshotter-grpc/config.toml

sudo systemctl restart containerd
sudo systemctl daemon-reload

sudo soci-snapshotter-grpc --config /etc/soci-snapshotter-grpc/config.toml

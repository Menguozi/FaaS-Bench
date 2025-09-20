#!/bin/bash

sudo cp config.toml /etc/containerd/config.toml
sudo cp config.json /etc/overlaybd-snapshotter/config.json

sudo systemctl stop containerd
sudo systemctl stop overlaybd-snapshotter
sudo systemctl stop overlaybd-tcmu
sudo rm -rf /opt/overlaybd/registry_cache/*
sudo rm -rf /opt/overlaybd/gzip_cache/*
sudo systemctl restart containerd
sudo systemctl restart overlaybd-snapshotter
sudo systemctl restart overlaybd-tcmu
sudo systemctl daemon-reload

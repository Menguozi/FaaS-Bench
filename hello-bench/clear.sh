#!/bin/bash

sudo nerdctl image prune -f --all

nerdctl container ls | cat -n
nerdctl image ls | cat -n
nerdctl rm -f $(nerdctl ps -aq)
nerdctl rmi -f $(nerdctl image ls -aq)

for c in `ctr c ls -q`; do nerdctl container stop $c; nerdctl container rm $c; done
for c in `ctr content ls -q`; do ctr content rm $c; done
for c in `ctr i ls -q`; do ctr i rm $c; done
    
sudo systemctl stop stargz-snapshotter
sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/fscache/*
sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/httpcache/*
    
sudo systemctl stop overlaybd-snapshotter
sudo systemctl stop overlaybd-tcmu
sudo rm -rf /opt/overlaybd/registry_cache/*
sudo rm -rf /opt/overlaybd/gzip_cache/*

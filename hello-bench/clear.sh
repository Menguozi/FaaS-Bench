#!/bin/bash

sudo nerdctl image prune -f --all

sudo nerdctl container ls | cat -n
sudo nerdctl image ls | cat -n
sudo nerdctl rm -f $(nerdctl ps -aq)
sudo nerdctl rmi -f $(nerdctl image ls -aq)

for c in `ctr c ls -q`; do nerdctl container stop $c; nerdctl container rm $c; done
for c in `ctr content ls -q`; do ctr content rm $c; done
for c in `ctr i ls -q`; do ctr i rm $c; done
    
sudo systemctl stop stargz-snapshotter
sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/fscache/*
sudo rm -rf /var/lib/containerd-stargz-grpc/stargz/httpcache/*
sudo systemctl start stargz-snapshotter
    
sudo systemctl stop overlaybd-snapshotter
sudo systemctl stop overlaybd-tcmu
sudo rm -rf /opt/overlaybd/registry_cache/*
sudo rm -rf /opt/overlaybd/gzip_cache/*
sudo systemctl start overlaybd-tcmu
sudo systemctl start overlaybd-snapshotter

sudo rm -rf /var/lib/nerdctl/1935db59/

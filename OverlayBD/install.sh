#!/bin/bash

sudo dpkg -X ./overlaybd-1.0.13-20240821.a117098.ubuntu1.22.04.x86_64.deb overlaybd
sudo dpkg -e ./overlaybd-1.0.13-20240821.a117098.ubuntu1.22.04.x86_64.deb overlaybd
sudo dpkg -X ./overlaybd-snapshotter_1.2.1-20240823023354.d4e1949_amd64.deb overlaybd-snapshotter
sudo dpkg -e ./overlaybd-snapshotter_1.2.1-20240823023354.d4e1949_amd64.deb overlaybd-snapshotter

sudo dpkg -i overlaybd-1.0.13-20240821.a117098.ubuntu1.22.04.x86_64.deb 
sudo systemctl enable /opt/overlaybd/overlaybd-tcmu.service
sudo systemctl start overlaybd-tcmu
sudo dpkg -i overlaybd-snapshotter_1.2.1-20240823023354.d4e1949_amd64.deb 
sudo systemctl enable /opt/overlaybd/snapshotter/overlaybd-snapshotter.service
sudo systemctl start overlaybd-snapshotter

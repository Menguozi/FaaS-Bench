# HelloBench

HelloBench is originally authored by @changweige. The original repository is not active for quite a long time. I forked the repository from commit `a22cae84983bd77187f8f5181de558c2c8dec045`.
Hello-bench is refined to adapt overlaybd performance test to attract more researcher.

Nowadays, several container image acceleration solutions around containerd and CRI-O/podman are being introduced. This forked project is aiming at building a universal container startup benchmark tool. Acceleration images usually differs OCI images by image tags. So the improved hello-bench can receive image tags now.

## Run HelloBench

This repository just contains the benchmark harness than runs various Docker, OCI and other acceleration container images e.g. nydus and stargz and overlaybd.

Please ensure your `nerdctl` is beyond v0.22

Both docker and containerd can manage container images. Containerd has more a flexible mechanism - snapshots - to add plugin and manage containers images. To run benchmark for different container engines, change hello-bench argument `--engine`.

- docker for Docker
- nerdctl for Containerd

```shell
./hello.py --engine nerdctl --op run --images python:latest
./hello.py --engine docker --op run --images python:latest

# To run benchmark for nydus snapshotter.
./hello.py --engine nerdctl --snapshotter nydus --op run --registry=menguozi --images python:nydusv6

# To run benchmark for overlaybd snapshotter.
./hello.py --engine nerdctl --snapshotter overlaybd --op run --registry=menguozi --images python:latest_obd
```

## Examples

TODO

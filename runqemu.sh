#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
exec qemu-system-aarch64 -M virt -cpu cortex-a53 -m 512M -nographic -smp 1 \
    -kernel buildroot/output/images/Image \
    -append "rootwait root=/dev/vda console=ttyAMA0" \
    -netdev user,id=eth0,hostfwd=tcp:127.0.0.1:10022-:22 \
    -device virtio-net-device,netdev=eth0 \
    -drive file=buildroot/output/images/rootfs.ext4,if=none,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 -device virtio-rng-pci

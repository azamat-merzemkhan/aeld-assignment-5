#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
git submodule update --init --recursive
if [ ! -f buildroot/.config ]; then
    make -C buildroot BR2_EXTERNAL=../base_external \
        BR2_DEFCONFIG=../base_external/configs/aesd_qemu_defconfig defconfig
else
    make -C buildroot BR2_EXTERNAL=../base_external
fi

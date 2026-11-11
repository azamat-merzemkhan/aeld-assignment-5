#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p base_external/configs
make -C buildroot savedefconfig BR2_DEFCONFIG=../base_external/configs/aesd_qemu_defconfig

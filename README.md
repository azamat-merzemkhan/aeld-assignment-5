# AELD Assignment 4: Buildroot ARM64 QEMU Image

Buildroot is pinned as a submodule to release **2024.02.13**. The external
`project_base` tree enables the finder application package, Dropbear SSH/SCP,
a root login password of `root`, DHCP, and an ext4 root filesystem.
The source package pins a tested commit from `aeld-assignment-3-and-later`.

## Build on Linux

Install the mandatory Buildroot tools and QEMU, or use the official course
`cuaesd/aesd-autotest:24-assignment4-buildroot` container.

```sh
git submodule update --init --recursive
./build.sh # configure a new checkout
./build.sh # build the configured image
./runqemu.sh
```

The package's Git site uses the SSH URL required by the course; configure
GitHub SSH access before building. The source repository is public. CI uses
a Git URL rewrite to read this public source over HTTPS, avoiding a persistent
SSH credential while retaining the required SSH package configuration.

The saved defconfig derives from `qemu_aarch64_virt_defconfig`. It uses the
supported prebuilt Arm external toolchain and the installed QEMU executable,
so no compiler or host QEMU build is needed. The target kernel still builds
from the course's default Linux 6.1.44 configuration.

## Configure or clean

Use `make -C buildroot menuconfig`, then `./save-config.sh` to save changes.
`./clean.sh` runs Buildroot's `distclean`; run `./build.sh` twice afterward.

## Validate

```sh
./scripts/validate-image.sh
SKIP_BUILD=1 DO_VALIDATE=1 ./full-test.sh
```

QEMU exposes SSH on **127.0.0.1:10022**. Log in as `root`, password `root`.
The validation script boots the generated image, runs `finder-test.sh` from
both `/` and `/tmp`, checks writer syslog messages, and retrieves the real
`/tmp/assignment4-result.txt` using SCP. The official course validation is
also run in CI. Logs and the retrieved result are uploaded as an artifact.

Installed paths:

- `/usr/bin/writer`, `/usr/bin/finder.sh`, `/usr/bin/finder-test.sh`
- `/usr/bin/tester.sh` (alias of the finder test)
- `/etc/finder-app/conf/username.txt` and `assignment.txt`

## Assistance disclosure

The implementation and validation workflow were prepared with OpenAI Codex
AI assistance using official course starter code, Buildroot configuration,
and assignment-autotest. No other student's solution was used.

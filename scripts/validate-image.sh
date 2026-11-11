#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
mkdir -p evidence
./runqemu.sh > evidence/qemu.log 2>&1 &
qemu_pid=$!
trap 'kill "$qemu_pid" 2>/dev/null || true; wait "$qemu_pid" 2>/dev/null || true' EXIT
ssh_options=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=3 -p 10022)
ready=0
for attempt in $(seq 1 60); do
    if sshpass -p root ssh "${ssh_options[@]}" root@127.0.0.1 true 2>/dev/null; then ready=1; break; fi
    sleep 2
done
if [ "$ready" != 1 ]; then cat evidence/qemu.log; exit 1; fi
ssh_guest() { sshpass -p root ssh "${ssh_options[@]}" root@127.0.0.1 "$@"; }
ssh_guest 'pidof aesdsocket && cd / && finder-test.sh' | tee evidence/startup.txt
./assignment-autotest/test/assignment5/sockettest.sh | tee evidence/sockettest.txt
ssh_guest '/etc/init.d/S99aesdsocket stop; test ! -e /var/tmp/aesdsocketdata && ! pidof aesdsocket; rc=$?; /etc/init.d/S99aesdsocket start; exit "$rc"'
./assignment-autotest/test/assignment5/sockettest.sh | tee evidence/sockettest-after-restart.txt
ssh_guest 'grep -E "Accepted connection from|Closed connection from|Caught signal, exiting" /var/log/messages' | tee evidence/syslog.txt
ssh_guest 'halt' || true
for attempt in $(seq 1 30); do
    if grep -q 'System halted' evidence/qemu.log; then break; fi
    sleep 1
done
grep -q 'System halted' evidence/qemu.log
kill "$qemu_pid" 2>/dev/null || true
wait "$qemu_pid" 2>/dev/null || true
trap - EXIT
mkdir -p evidence/rootfs-check
debugfs -R 'stat /var/tmp/aesdsocketdata' buildroot/output/images/rootfs.ext4 2>&1 | tee evidence/data-cleanup.txt
grep -q 'File not found' evidence/data-cleanup.txt

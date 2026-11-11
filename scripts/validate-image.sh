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
    if sshpass -p root ssh "${ssh_options[@]}" root@127.0.0.1 true 2>/dev/null; then
        ready=1
        break
    fi
    sleep 2
done
if [ "$ready" != 1 ]; then
    cat evidence/qemu.log
    exit 1
fi
sshpass -p root ssh "${ssh_options[@]}" root@127.0.0.1 \
    'cd / && finder-test.sh && cd /tmp && finder-test.sh && grep -F "Writing" /var/log/messages' \
    | tee evidence/ssh-validation.txt
sshpass -p root scp -O -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 10022 \
    root@127.0.0.1:/tmp/assignment4-result.txt evidence/assignment4-result.txt
grep -F 'The number of files are 10 and the number of matching lines are 10' evidence/assignment4-result.txt

#!/bin/sh
set -u
what=${1:-all}

record() {
    echo "== pw-record: microphone and system output (monitor), 5 s each, 16 kHz mono"
    mkdir -p recordings
    timeout 5 pw-record --rate 16000 --channels 1 recordings/mic.wav
    timeout 5 pw-record --rate 16000 --channels 1 -P '{ stream.capture.sink = true }' recordings/monitor.wav
    ls -l recordings/
}

latency() {
    echo "== cyclictest: wake-up latency, 1 ms period, 30 s, idle system"
    cyclictest -m -p 90 -i 1000 -D 30s -q
    echo "== same, idle, without RT priority (SCHED_OTHER)"
    cyclictest -m -p 0 --policy=other -i 1000 -D 30s -q
    echo "== cyclictest under load (stress-ng on all CPUs + memory)"
    stress-ng --cpu 0 --vm 2 --timeout 35s >/dev/null 2>&1 &
    cyclictest -m -p 90 -i 1000 -D 30s -q
    wait
    echo "== same under load, without RT priority (SCHED_OTHER)"
    stress-ng --cpu 0 --vm 2 --timeout 35s >/dev/null 2>&1 &
    cyclictest -m -p 0 --policy=other -i 1000 -D 30s -q
    wait
}

netns() {
    echo "== unshare -rn: new network namespace, only 'lo' is visible"
    unshare -rn cat /proc/net/dev
    echo "== curl inside it fails"
    unshare -rn curl -sS -m 5 https://example.com -o /dev/null
    echo "== PipeWire still reachable (UNIX socket on the filesystem)"
    unshare -rn pw-cli info 0 | grep version
}

case $what in
    record) record ;;
    latency) latency ;;
    netns) netns ;;
    all) record; latency; netns ;;
    *) echo "usage: $0 [record|latency|netns|all]"; exit 1 ;;
esac

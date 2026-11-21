#!/bin/sh
fail=0
ok()   { printf '  OK       %s\n' "$1"; }
bad()  { printf '  MISSING  %s  ->  %s\n' "$1" "$2"; fail=1; }
have() { command -v "$1" >/dev/null 2>&1; }

echo "Toolchain"
for t in gcc make pkg-config; do
    if have "$t"; then ok "$t"; else bad "$t" "sudo apt install build-essential pkg-config"; fi
done
if pkg-config --exists libpipewire-0.3; then
    ok "libpipewire-0.3 headers ($(pkg-config --modversion libpipewire-0.3))"
else
    bad "libpipewire-0.3 headers" "sudo apt install libpipewire-0.3-dev"
fi

echo "Audio"
if pw-cli info 0 >/dev/null 2>&1; then ok "PipeWire running"; else bad "PipeWire running" "systemctl --user start pipewire"; fi
for t in pw-record pw-top; do
    if have "$t"; then ok "$t"; else bad "$t" "sudo apt install pipewire-bin"; fi
done

echo "Real-time"
rtprio=$(ulimit -r)
if [ "$rtprio" != 0 ]; then ok "RT priority limit (ulimit -r = $rtprio)"; else bad "RT priority limit (ulimit -r = 0)" "docs/setup.md, step 2"; fi
ok "locked memory limit (ulimit -l = $(ulimit -l) kB)"
for t in cyclictest stress-ng; do
    if have "$t"; then ok "$t"; else bad "$t" "sudo apt install rt-tests stress-ng"; fi
done

echo "Isolation"
# Informational only: Ubuntu's AppArmor blocks this for most programs; the daemon relies on seccomp.
if unshare -rn true 2>/dev/null; then
    ok "unprivileged network namespace (unshare -rn)"
else
    printf '  INFO     unshare -rn blocked by AppArmor (normal on Ubuntu 24.04); seccomp is used instead\n'
fi

exit $fail

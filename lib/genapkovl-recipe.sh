#!/bin/sh -e
# apkovl = recipe overlay (/etc files + runlevels) + recipe world file.
HOSTNAME="$1"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp -a /in/overlay/. "$tmp"/
mkdir -p "$tmp"/etc/apk
{ echo alpine-base; cat /in/world; } | sort -u > "$tmp"/etc/apk/world
# Without this marker, initramfs-init skips the stock live-boot services (modloop,
# hwdrivers, firstboot, ...) whenever an apkovl is present.
touch "$tmp"/etc/.default_boot_services
tar -c -C "$tmp" etc | gzip -9n > "$HOSTNAME".apkovl.tar.gz

#!/bin/sh -e
# apkovl = recipe overlay (/etc files + runlevels) + recipe world file.
HOSTNAME="$1"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp -a /in/overlay/. "$tmp"/
mkdir -p "$tmp"/etc/apk
{ echo alpine-base; cat /in/world; } | sort -u > "$tmp"/etc/apk/world
tar -c -C "$tmp" etc | gzip -9n > "$HOSTNAME".apkovl.tar.gz

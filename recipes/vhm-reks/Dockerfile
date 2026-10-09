# Recipe: VHM Docker-ready Alpine for Google "Reks" Chromebooks (MrChromebox UEFI).
# `ARG ALPINE_VERSION=latest` makes build.sh resolve the newest stable Alpine;
# put a concrete version (e.g. 3.21.4) here to pin instead.
ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION} AS rootfs

# Base system. NOTE: no separate `acpid` package: the busybox acpid applet
# (init script from busybox-openrc, shipped by alpine-base) reads /etc/acpi/<EVENT>/*.
RUN apk add --no-cache alpine-base \
      chrony chrony-openrc openssh doas tzdata \
      iw wpa_supplicant \
      dosfstools e2fsprogs \
      linux-lts \
      linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek \
      linux-firmware-other linux-firmware-rtl_bt

# grub-efi: its trigger runs grub-probe, which fails on a container rootfs; setup-disk runs it at install time
RUN apk add --no-cache --no-scripts grub-efi

# Docker-ready host + maintenance tools
RUN apk add --no-cache docker docker-openrc docker-cli-compose docker-cli-buildx \
      bash curl git tmux

# Customizations: power button / lid, GRUB, mkinitfs, keymap, doas, ttyS0, timezone
COPY recipes/vhm-reks/overlay/ /

# Services
RUN for s in devfs dmesg hwdrivers mdev; do rc-update add $s sysinit; done \
 && for s in bootmisc hostname hwclock loadkmap modules networking seedrng swap sysctl syslog; do rc-update add $s boot; done \
 && for s in killprocs mount-ro savecache; do rc-update add $s shutdown; done \
 && for s in acpid cgroups chronyd crond docker sshd local; do rc-update add $s default; done

LABEL org.opencontainers.image.title="vhm-reks"

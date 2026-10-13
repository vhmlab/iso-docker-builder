# Recipe: VHM Docker-ready Alpine for Google "Reks" Chromebooks (MrChromebox UEFI).
# `ARG ALPINE_VERSION=latest` makes build.sh resolve the newest stable Alpine;
# put a concrete version (e.g. 3.21.4) here to pin instead.
ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION} AS rootfs

# Only what a default setup-alpine does NOT install. A stock install on Reks hardware
# (checked on vhm22) already brings chrony, doas, dosfstools, e2fsprogs, linux-lts,
# grub-efi and linux-firmware-{i915,intel,mediatek,other,rtl_bt}, and enables
# acpid/chronyd/crond/sshd plus the sysinit/boot/shutdown services.
# alpine-base and openssh stay so the Docker image has OpenRC and sshd.
# NOTE: no separate `acpid` package: the busybox acpid applet (init script from
# busybox-openrc, shipped by alpine-base) reads /etc/acpi/<EVENT>/*.
RUN apk add --no-cache alpine-base openssh tzdata

# Wi-Fi: setup-alpine installs these only when Wi-Fi is configured during setup
RUN apk add --no-cache iw wpa_supplicant

# Docker-ready host + maintenance tools
RUN apk add --no-cache docker docker-openrc docker-cli-compose docker-cli-buildx \
      bash curl git tmux

# Customizations: power button / lid, GRUB, mkinitfs, keymap, ttyS0, timezone,
# setup-alpine answer file + auto-start on the live console (etc/vhm, etc/profile.d),
# community repo (Docker lives there; setup-alpine leaves it commented out)
COPY recipes/vhm-reks/overlay/ /

# Services beyond the stock ones. acpid is stock too, but the power/lid handlers depend on it.
# docker/cgroups are enabled on first boot of the installed system by
# /etc/local.d/enable-docker.start, so they do not run on the live ISO.
RUN for s in acpid local; do rc-update add $s default; done

LABEL org.opencontainers.image.title="vhm-reks"

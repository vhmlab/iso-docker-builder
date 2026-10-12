# Writing a recipe

A recipe is a directory `recipes/<name>/` with:

- `Dockerfile`: must declare `ARG ALPINE_VERSION=latest` before the first `FROM`, and a stage
  named `rootfs` (`FROM alpine:${ALPINE_VERSION} AS rootfs`).
- `overlay/`: files copied to `/` in the image and, via the apkovl, onto the installed system.

Inside the `rootfs` stage:
- `RUN apk add ...` decides the package set (the resulting `/etc/apk/world` becomes the ISO's).
  Include `alpine-base`. List only what a default `setup-alpine` does not install: the installer
  already adds the kernel, bootloader, detected firmware, chrony, doas, openssh and the stock
  services. The ISO itself always carries the full stock `standard` package set.
- `COPY recipes/<name>/overlay/ /` for config files.
- `RUN rc-update add <service> <runlevel>` for services beyond the stock ones (`/etc/runlevels`
  is carried into the ISO; the stock sysinit/boot/shutdown services are added by the installer).

`setup-disk` copies the live system's `/etc` (`lbu package`) onto the installed disk before
installing packages, so overlay files and runlevels end up on the installed system.

Not for recipes: hostnames, machine-ids, SSH host keys, passwords, Wi-Fi keys, disk UUIDs.
Provision those per machine.

`vhm-reks/` is the reference recipe: Docker-ready Alpine for Google "Reks" Chromebooks, keeping the
custom power-button and lid handlers in `overlay/etc/acpi/`.

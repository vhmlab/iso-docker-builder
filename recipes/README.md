# Writing a recipe

A recipe is a directory `recipes/<name>/` with:

- `Dockerfile`: must declare `ARG ALPINE_VERSION=latest` before the first `FROM`, and a stage
  named `rootfs` (`FROM alpine:${ALPINE_VERSION} AS rootfs`).
- `overlay/`: files copied to `/` in the image and, via the apkovl, onto the installed system.

Inside the `rootfs` stage:
- `RUN apk add ...` decides the package set (the resulting `/etc/apk/world` becomes the ISO's).
  Include `alpine-base`; include `linux-lts`, `grub-efi` and firmware if you want a bootable system.
- `COPY recipes/<name>/overlay/ /` for config files.
- `RUN rc-update add <service> <runlevel>` for services (`/etc/runlevels` is carried into the ISO).

Not for recipes: hostnames, machine-ids, SSH host keys, passwords, Wi-Fi keys, disk UUIDs.
Provision those per machine.

`vhm-reks/` is the reference recipe: Docker-ready Alpine for Google "Reks" Chromebooks, keeping the
custom power-button and lid handlers in `overlay/etc/acpi/`.

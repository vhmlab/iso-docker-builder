# alpine-image-builder

Builds a bootable Alpine installer ISO **and** an equivalent Docker image from one
Dockerfile-style recipe.

```
./build.sh recipes/vhm-reks            # image + ISO
./build.sh recipes/vhm-reks --image    # Docker image only (fast, for testing packages/config)
./build.sh recipes/vhm-reks --iso      # same as default; the image is always built first
./build.sh recipes/vhm-reks --cached   # reuse Docker layer cache (default: fresh, --pull --no-cache)
```

Output goes to `out/`:
- `out/<recipe>-<timestamp>/*.iso`
- `out/<recipe>-<timestamp>.manifest`: Alpine version, kernel, every package=version, ISO sha256
- Docker image `alpine-image-builder/<recipe>:<alpine-version>` and `:latest`

## Versions
`build.sh` resolves the newest stable Alpine from `latest-releases.yaml` and builds with fresh
package layers, so every build is "latest". To pin, set a concrete `ARG ALPINE_VERSION=3.21.4`
in the recipe. The manifest records what was actually used.

## How it works
The recipe's Dockerfile defines the `rootfs` stage (packages, `COPY` of config, `rc-update add`).
`build.sh` appends `lib/iso-stages.Dockerfile`, which takes that stage's `/etc/apk/world`,
`/etc/runlevels` and the recipe's `overlay/` and feeds them to Alpine's `mkimage.sh`
(`lib/mkimg.recipe.sh`, `lib/genapkovl-recipe.sh`). One recipe, two outputs, no drift.

The Docker image verifies packages and config; it can't verify boot behavior (power button,
lid, GRUB). Test that on hardware.

Requirements: Docker with BuildKit/buildx, network access. Nothing else is installed on the host.

See `recipes/README.md` to write a recipe.

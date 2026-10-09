#!/bin/sh
# Usage: ./build.sh recipes/<name> [--image] [--iso] [--cached]
# Builds the recipe's Dockerfile into a Docker image (--image) and/or a bootable ISO (--iso).
# Latest stable Alpine and latest packages are used unless the recipe pins ALPINE_VERSION.
set -eu
cd "$(dirname "$0")"

recipe_dir="${1:-}"; [ -n "$recipe_dir" ] && shift || { sed -n '2,4p' "$0"; exit 1; }
recipe_dir="${recipe_dir%/}"; recipe="$(basename "$recipe_dir")"
[ -f "$recipe_dir/Dockerfile" ] || { echo "no $recipe_dir/Dockerfile" >&2; exit 1; }
want_image=0; want_iso=0; cache="--no-cache --pull"
for a in "$@"; do case "$a" in
	--image) want_image=1 ;; --iso) want_iso=1 ;; --cached) cache="" ;;
	*) echo "unknown option $a" >&2; exit 1 ;; esac; done
[ $((want_image + want_iso)) -eq 0 ] && want_image=1 && want_iso=1

# --- resolve the Alpine version: recipe pin wins, otherwise newest stable ---
pin="$(sed -n 's/^ARG ALPINE_VERSION=//p' "$recipe_dir/Dockerfile" | head -1)"
if [ -n "$pin" ] && [ "$pin" != latest ]; then
	version="$pin"
else
	# in latest-releases.yaml, version precedes flavor within each entry
	version="$(curl -fsS https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/latest-releases.yaml \
		| awk '/^  version:/ {v=$2} /flavor: alpine-standard$/ {print v; exit}')"
fi
[ -n "$version" ] || { echo "could not resolve latest Alpine version" >&2; exit 1; }
branch="${version%.*}"
echo "== recipe=$recipe alpine=$version (branch $branch)"

# --- assemble Dockerfile = recipe + shared ISO stages ---
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
cat "$recipe_dir/Dockerfile" lib/iso-stages.Dockerfile > "$work/Dockerfile"
args="--build-arg ALPINE_VERSION=$version --build-arg BRANCH=$branch --build-arg RECIPE=$recipe"
tag="alpine-image-builder/$recipe:$version"
mkdir -p out; stamp="$(date +%Y%m%d-%H%M%S)"

# The image is always built first (the ISO stage reuses its layers).
docker build $cache $args -f "$work/Dockerfile" --target rootfs -t "$tag" -t "alpine-image-builder/$recipe:latest" .
manifest="out/$recipe-$stamp.manifest"
{ echo "recipe: $recipe"; echo "alpine: $version"; echo "built: $stamp"
  echo "kernel: $(docker run --rm "$tag" apk list -I linux-lts | cut -d" " -f1)"
  echo "packages:"; docker run --rm "$tag" apk info -v | sort | sed 's/^/  /'; } > "$manifest"

if [ $want_iso -eq 1 ]; then
	isodir="out/$recipe-$stamp"; mkdir -p "$isodir"
	docker build $args --build-arg CACHEBUST="$stamp" -f "$work/Dockerfile" --target iso --output "type=local,dest=$isodir" .
	for f in "$isodir"/*.iso; do
		sum="$(sha256sum "$f" | cut -d' ' -f1)"; echo "iso: $(basename "$f") sha256=$sum" >> "$manifest"
	done
fi
echo "== done. manifest: $manifest"; [ $want_image -eq 1 ] && echo "== image: $tag"

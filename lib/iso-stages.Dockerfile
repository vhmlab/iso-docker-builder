
# ---- appended to every recipe by build.sh: turns the `rootfs` stage into an ISO ----
FROM alpine:${ALPINE_VERSION} AS isobuilder
ARG ALPINE_VERSION
ARG RECIPE
ARG CACHEBUST=0
RUN echo "$CACHEBUST" >/dev/null \
 && apk add --no-cache alpine-sdk build-base apk-tools alpine-conf busybox fakeroot \
      syslinux xorriso squashfs-tools mtools dosfstools grub-efi git
RUN adduser -D build && addgroup build abuild
USER build
RUN abuild-keygen -a -n >/dev/null
USER root
RUN cp /home/build/.abuild/*.rsa.pub /etc/apk/keys/
ARG BRANCH
RUN git clone -q --depth 1 -b "${BRANCH}-stable" https://gitlab.alpinelinux.org/alpine/aports.git /home/build/aports

# Inputs taken from the recipe's rootfs stage (single source of truth)
COPY --from=rootfs /etc/apk/world /in/world
COPY --from=rootfs /etc/runlevels /in/overlay/etc/runlevels
COPY recipes/${RECIPE}/overlay/ /in/overlay/
COPY lib/mkimg.recipe.sh lib/genapkovl-recipe.sh /home/build/aports/scripts/
RUN chmod +x /home/build/aports/scripts/genapkovl-recipe.sh \
 && chown -R build /home/build /in && mkdir -p /out && chown build /out

USER build
WORKDIR /home/build/aports/scripts
RUN TMPDIR=/tmp sh mkimage.sh --tag "${ALPINE_VERSION}-${RECIPE}" --outdir /out \
      --workdir /tmp/w --arch x86_64 --profile recipe \
      --repository "https://dl-cdn.alpinelinux.org/alpine/v${BRANCH}/main" \
      --repository "https://dl-cdn.alpinelinux.org/alpine/v${BRANCH}/community"

FROM scratch AS iso
COPY --from=isobuilder /out/ /

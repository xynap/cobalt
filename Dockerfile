# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files

# akmods
FROM ghcr.io/ublue-os/akmods:coreos-stable-43 AS akmods-common
FROM ghcr.io/ublue-os/akmods-nvidia-open:coreos-stable-43 AS akmods-nvidia
FROM ghcr.io/ublue-os/akmods-zfs:coreos-testing-43 AS akmods-zfs

# Base Image
FROM quay.io/fedora/fedora-coreos:stable

### MODIFICATIONS
## Make modifications desired in your image and install packages by modifying the build.sh script
## The following RUN directive does all the things required to run "build.sh" as recommended
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods-common,src=/rpms,dst=/tmp/akmods-common \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/akmods-nvidia \
    --mount=type=bind,from=akmods-zfs,src=/rpms,dst=/tmp/akmods-zfs \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh

### LINTING
## Verify final image and contents are correct
RUN bootc container lint

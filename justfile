build-minimal:
    sudo podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-minimal.yaml \
        -t localhost/fedora-bootc-minimal \
        .

build-full:
    sudo podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-full.yaml \
        -t localhost/fedora-bootc-full \
        .

build-atomic-base:
    sudo podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-atomic-base.yaml \
        -t localhost/fedora-bootc-atomic-base \
        .

build-atomic-gnome:
    sudo podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-atomic-gnome.yaml \
        -t localhost/fedora-bootc-atomic-gnome \
        .

comps-sync:
    #!/usr/bin/env bash
    pushd ./helpers/comps-sync
    podman build \
        -t localhost/comps-sync \
        .
    popd
    rm -rf fedora-comps
    git clone https://pagure.io/fedora-comps.git
    default_variant=base
    version="$(rpm-ostree compose tree --print-only --repo=repo fedora-bootc-atomic-${default_variant}.yaml | jq -r '."mutate-os-release"')"
    podman run \
        --rm \
        -v $(pwd):/mnt:Z \
        localhost/comps-sync \
        /app/comps-sync.py \
          /mnt/fedora-comps/comps-f40.xml.in --save

build-atomic-base-qcow:
    #!/usr/bin/env bash
    pushd _osbuild
    sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/config.toml:/config.toml \
    -v $(pwd)/output:/output -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type qcow2 --rootfs ext4 \
    --local localhost/fedora-bootc-base:latest
    popd
    sudo chown -R $(whoami):$(whoami) _osbuild/output

build-atomic-gnome-qcow:
    #!/usr/bin/env bash
    pushd _osbuild
    sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/config.toml:/config.toml \
    -v $(pwd)/output:/output -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type qcow2 --rootfs ext4 \
    --local localhost/fedora-bootc-atomic-gnome:latest
    popd
    sudo chown -R $(whoami):$(whoami) _osbuild/output

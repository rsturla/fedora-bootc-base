comps-sync:
    #!/usr/bin/env bash
    set -euo
    pushd ./scripts/comps-sync
    podman build -t comps-sync:local .
    popd
    # rm -rf fedora-comps
    # git clone https://pagure.io/fedora-comps.git
    version=$(jq -r '.Labels."redhat.version-id"' fedora-bootc-config.json)
    echo "Version: $version"
    podman run \
        --rm \
        -v $(pwd):/mnt:Z \
        comps-sync:local \
        /app/comps-sync.py \
          /mnt/fedora-comps/comps-f${version}.xml.in --save

coreos-comps-sync:
    #!/usr/bin/env bash
    git clone https://github.com/coreos/fedora-coreos-config
    pushd fedora-coreos-config
    mkdir -p ../02-server/coreos
    cp -r ./manifests ../02-server/coreos
    cp -r ./overlay.d ../02-server/coreos
    popd
    rm -rf fedora-coreos-config

build-minimal:
    podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --no-cache \
        --build-arg MANIFEST=./fedora-bootc-minimal.yaml \
        -t localhost/fedora-bootc-minimal \
        .

build-full:
    podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --no-cache \
        --build-arg MANIFEST=./fedora-bootc-full.yaml \
        -t localhost/fedora-bootc-full \
        .

build-atomic desktop:
    podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-atomic-{{desktop}}.yaml \
        -t localhost/fedora-bootc-atomic-{{desktop}} \
        .

build-coreos:
    podman build \
        --security-opt label=disable \
        --cap-add=all \
        --device /dev/fuse \
        --build-arg MANIFEST=./fedora-bootc-coreos.yaml \
        -t localhost/fedora-bootc-coreos \
        .

build-atomic-qcow desktop:
    #!/usr/bin/env bash
    pushd .osbuild
    mkdir -p output
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
    --local localhost/fedora-bootc-atomic-{{desktop}}:latest
    popd
    sudo chown -R $(whoami):$(whoami) .osbuild/output

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

comps-sync:
    #!/usr/bin/env bash
    pushd ./helpers/comps-sync
    podman build \
        -t localhost/comps-sync \
        .
    popd
    rm -rf fedora-comps
    # git clone https://pagure.io/fedora-comps.git
    default_variant=base
    version="$(rpm-ostree compose tree --print-only --repo=repo fedora-bootc-atomic-${default_variant}.yaml | jq -r '."mutate-os-release"')"
    podman run \
        --rm \
        -v $(pwd):/mnt:Z \
        localhost/comps-sync /app/comps-sync.py \
          fedora-comps/comps-f40.xml

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

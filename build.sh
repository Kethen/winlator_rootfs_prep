set -xe

source package_list

rm -rf out
mkdir out

build_image () {
    arch=$1
    arch_32=$2
    packages=$(for f in $PACKAGES; do echo $f; done)
    packages_32=$(for f in $PACKAGES_32; do echo $f:$arch_32; done)

    podman run \
        --rm -it \
        --arch $arch \
        --security-opt label=disable \
        --entrypoint /bin/bash \
        -v ./out:/out \
        -e DEBIAN_FRONTEND=noninteractive \
        -w / \
        debian:bookworm \
        -c "
        set -xe
        dpkg --add-architecture $arch_32
        apt update
        apt install -y $(echo $packages) $(echo $packages_32)
        tar -cf /out/bookworm_$arch.tar bin etc lib opt run usr var
        "
}

build_image x86_64 i386
build_image arm64 armhf

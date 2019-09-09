#!/bin/sh
set -ex

export KERNEL=kernel7

rm -rf out
PATH=$HOME/raspi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
make O=out ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mrproper

PATH=$HOME/raspi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
make O=out ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- rpi3_defconfig

PATH=$HOME/raspi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
make -j4 O=out ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs


# install
mkdir -p out/target/boot/overlays
cp out/arch/arm/boot/zImage out/target/boot/$KERNEL.img
cp out/arch/arm/boot/dts/*.dtb out/target/boot/
cp out/arch/arm/boot/dts/overlays/*.dtb* out/target/boot/overlays/

mkdir -p out/target/rootfs
PATH=$HOME/raspi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
make O=out ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=target/rootfs INSTALL_MOD_STRIP=1 modules_install

rm -f out/target/rootfs/lib/modules/*/build
rm -f out/target/rootfs/lib/modules/*/source

tar czf out/boot.tar.gz --owner=0 --group=0 -C out/target/boot .
tar czf out/rootfs.tar.gz --owner=0 --group=0 -C out/target/rootfs .


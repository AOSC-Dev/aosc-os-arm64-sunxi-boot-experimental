pushd build
git clone https://github.com/Icenowy/linux -b sunxi64-4.11-rc1 --depth=1
cd linux
git clone https://github.com/Icenowy/rtl8723bs -b 4.11-fix --depth=1
cp ../../linux_config .config
make ARCH=arm64 CROSS_COMPILE=/opt/abcross/arm64/bin/aarch64-aosc-linux-gnu- -j$(nproc)
mkdir -p ../../out/linux-kernel-sunxi64
cp arch/arm64/boot/Image ../../out/linux-kernel-sunxi64/
tmpdir=$(mktemp -d)
make ARCH=arm64 CROSS_COMPILE=/opt/abcross/arm64/bin/aarch64-aosc-linux-gnu- INSTALL_MOD_PATH="$tmpdir" modules_install
EXTRA_KMOD_DIR="$(echo "$tmpdir"/lib/modules/*)/kernel/extra"
mkdir -p "$EXTRA_KMOD_DIR"
cd rtl8723bs
make ARCH=arm64 CROSS_COMPILE=/opt/abcross/arm64/bin/aarch64-aosc-linux-gnu- KSRC=$PWD/..
cp *.ko "$EXTRA_KMOD_DIR"
cd ..
depmod -b "$tmpdir" $(basename $(readlink -f $EXTRA_KMOD_DIR/../..))
cp -r "$tmpdir"/lib/modules ../../out/linux-kernel-sunxi64/
rm -rf "$tmpdir"
for i in sun50i-h5-orangepi-pc2 sun50i-a64-pine64 sun50i-a64-pine64-plus
do
	mkdir -p ../../out/dtb-$i
	cp arch/arm64/boot/dts/allwinner/$i.dtb ../../out/dtb-$i/dtb.dtb
done
popd

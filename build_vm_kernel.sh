#!/bin/bash
OPTION=$1

# Config
echo "Pulling in the latest kernel config"
cd /usr/src/kernel
git checkout vm
git pull
echo ""

# Kernel
echo "Pulling in the latest kernel source"
cd /usr/src/linux-stable
if [[ $OPTION == '-c' ]]; then
    make clean
fi
git pull
cp /usr/src/kernel/.config ./
make oldconfig
cp .config /usr/src/kernel
cd /usr/src/kernel
git commit .config
git push
echo ""

# Build
cd /usr/src/linux-stable
VERSION=$(head -n3 .config|tail -n1|awk '{print $3}')
echo "Building kernel $VERSION"
if [[ $OPTION != "-s" ]]; then
  INSTALL_MOD_PATH=/var/kernel/modules make -j 3 -l 2
  if [[ $? != 0 ]]; then
    echo "Building kernel failed"
    exit
  fi
fi
rm -r /var/kernel/modules/lib
INSTALL_MOD_PATH=/var/kernel/modules make modules_install
if [[ $? != 0 ]]; then
  echo "Installing modules failed"
  exit
fi
echo ""

# Installing kernel
echo "Installing kernel"
cp arch/x86/boot/bzImage /var/kernel/vmlinuz-$VERSION
ln -s /var/kernel/modules/lib/modules/$VERSION /lib/modules/$VERSION
cp /usr/src/linux-stable/.config /boot/config-$VERSION
echo ""

# Initramfs
echo "Building initramfs"
dracut --force --nolvm /var/kernel/initramfs.img-$VERSION $VERSION
if [[ $? != 0 ]]; then
  echo "Building initramfs failed"
  exit
fi
echo ""

# Modules CD
echo "Building modules CD"
mkisofs -J -ldots -allow-multidot -v -V 'modules-cd' -o /var/kernel/modules-$VERSION.iso /var/kernel/modules/lib/modules
if [[ $? != 0 ]]; then
  echo "Building modules iso failed"
  exit
fi
echo ""

# Cleanup
echo "Clean up and finalize"
cd /var/kernel
rm kernel
ln -s vmlinuz-$VERSION kernel
rm initramfs
ln -s initramfs.img-$VERSION initramfs
rm modules.iso
ln -s modules-$VERSION.iso modules.iso
chown qemu:qemu ./*
rm /boot/config-$VERSION

echo "You can now reboot the vm"

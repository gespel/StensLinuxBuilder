sudo apt install bc binutils bison dwarves flex gcc git gnupg2 gzip libelf-dev libncurses5-dev libssl-dev make openssl pahole perl-base rsync tar xz-utils autoconf gperf autopoint texinfo texi2html gettext gawk bzip2 qemu-system-x86 libtool

mkdir LFN
cd LFN

mkdir root
cd root

mkdir boot
mkdir proc
mkdir sys
mkdir dev

mkdir usr
cd usr

mkdir lib
mkdir lib64
mkdir bin
mkdir sbin
cd ..

ln -s usr/lib lib
ln -s usr/lib64 lib64
ln -s usr/bin bin
ln -s usr/sbin sbin

cd ..

export LFN="/home/sten/LFN/root"

git clone --depth 1 https://github.com/torvalds/linux
cd linux

make tinyconfig
make menuconfig

make -j8

mv arch/x86/boot/bzImage ..
cd ..
mv bzImage root/boot/

#BASH
git clone --depth 1 https://git.savannah.gnu.org/git/bash.git

mkdir bash-build
cd bash-build

#lets show how configure works
../bash/configure --help

../bash/configure --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

ln -s bash root/bin/sh

#lets take a look at our bin folder
ls root/bin

#COREUTILS
git clone --depth 1 https://github.com/coreutils/coreutils

mkdir coreutils-build

cd coreutils
./bootstrap
cd ..

cd coreutils-build
../coreutils/configure --without-selinux --disable-libcap --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

#lets take a look at our bin folder
ls root/bin

#UTIL-LINUX
git clone --depth 1 https://github.com/util-linux/util-linux

mkdir util-build

cd util-linux
./autogen.sh
cd ..

cd util-build
../util-linux/configure --disable-liblastlog2 --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

#lets take a look at our bin folder
ls root/bin

#NANO
git clone --depth 1 git://git.savannah.gnu.org/nano.git

mkdir nano-build

cd nano
./autogen.sh
cd ..

cd nano-build
../nano/configure --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

#lets take a look at our bin folder
ls root/bin

#GLIBC
git clone --depth 1 https://sourceware.org/git/glibc

mkdir glibc-build

cd glibc-build
../glibc/configure --libdir=/lib --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

#lets take a look at our lib64 folder
ls root/lib64

#NCURSES
wget https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz

tar -xvzf ncurses-6.5.tar.gz

mkdir ncurses-build

cd ncurses-build
../ncurses-6.5/configure --with-shared --with-termlib --enable-widec --with-versioned-syms --prefix=/usr

make -j8
make DESTDIR=$LFN install
cd ..

cd root
ln -s libncursesw.so.6 lib/libncurses.so.6
ln -s libtinfow.so.6 lib/libtinfo.so.6

#ETC
nano etc/ld.so.conf

ldconfig -v -r ./

#note that in the lib shown there is no libncurses.so.6, this is because the ld cache produced by ldconfig does not detect symlinks, this is why we needed the --libdir=/lib in the configure of glibc to add a system search path that can be shown using:
bin/ld.so --help

nano sbin/init

chmod +x sbin/init
cd ..

dd if=/dev/zero of=disk.img bs=1M count=1024

fdisk disk.img

sudo losetup -fP --show disk.img

sudo mkfs.ext4 /dev/loop0

sudo mount /dev/loop0 /mnt

sudo cp -R root/* /mnt/

sudo grub-install --target=i386-pc --root-directory=/mnt --no-floppy --modules="normal part_msdos ext2 multiboot" /dev/loop0

sudo nano /mnt/boot/grub/grub.cfg

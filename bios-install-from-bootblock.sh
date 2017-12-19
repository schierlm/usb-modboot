#!/bin/sh
if [ -z "$1" -o ! -b "$1" ]; then
	echo "Usage: sh ./bios-install-from-bootblock /dev/sd<x>"
	exit 1
fi
clear
echo Install GRUB for USB-ModBoot to device $1.
echo
read -p "Are you sure (y/N)? " yn
case $yn in
	[Yy]* ) break;;
	* ) exit;;
esac
echo Installing...
xzcat ./usb-bootblock.img.xz | dd of=$1 bs=446 count=1 status=none
xzcat ./usb-bootblock.img.xz | dd of=$1 bs=512 count=62 skip=1 seek=1 status=none
echo Done.

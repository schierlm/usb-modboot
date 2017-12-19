#!/bin/sh
DISK=`grub-probe -t disk "$0"`
clear
echo Install GRUB for USB-ModBoot to device $DISK.
echo
read -p "Are you sure (y/N)? " yn
case $yn in
	[Yy]* ) break;;
	* ) exit;;
esac
echo Installing...
grub-bios-setup -d . "$DISK"
echo Done.

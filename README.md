# usb-modboot
Boot multiple systems from a single GRUB2-powered USB drive (just drop ISO or other modules to integrate into menu)


## Design Principles

- Modular design: You can choose yourself which modules you want to add to your USB key,
  so things you don't need won't need any space on your USB key. The core files (which
  are required in all cases) have a total size of less than 6 MB. The menu will adjust
  automatically as you add or remove module files.

- Installing USB-Modboot (making a USB key bootable for the first time) is possible in
  as many operating systems as possible. Currently it can be done on Windows and Linux
  (on Linux there are two methods depending on whether you have grub-bios-install binary
  available or not). Alternatively, a dd-able USB image is available that you can `dd`
  to the key on supported OSes, even when they are not Windows or Linux (deleting all
  your data on the USB key.) When only EFI boot is required (no legacy BIOS), there is
  no special install procedure at all - just format your USB-key as FAT32 and copy all
  files to it.

- Adding or updating modules is possible on all operating systems that can write FAT32
  partitions, even mobile devices with USB to go. Some modules may require unpacking .zip
  files, but even that shmould be possible on most devices/operating systems.

- ISO files of most Linux distributions (which include a loopback.cfg file), as well as
  EFI utilities (like EFI shell) are valid modules, so you can add them without needing
  any extra files. Other modules will need some extra files (available for download here),
  but the original (ISO etc.) files will be unchanged on the USB key to make updating
  (and reuing them in VMs) easier. The menu label of ISO files is tried to be determined
  from the content (e. g. `/.disk/info`) with a fallback derived from the file name. You
  can modify this fallback by adding a menu label to the file name (in square brackets)
  or by addng a .ini file next to the module that contains the desired menu label.

- When you are like me and add lots of modules, the menu can get quite cluttered.
  Therefore, it is possible to manually curate a favourites menu (by editing a text file
  on the USB key), which may also optionally include submenus. All other modules will remain
  in the "All Boot Modules" menu.

- The USB key can be booted either via legacy BIOS mode or via (64-bit) UEFI mode (including
  Secure Boot); some modules might not work in one of the modes, though. Also, an additional
  module is available to add 32-bit EFI mode (used on some tablets and netbooks), and another
  one to make it bootable (chainloadable) from USB-Loader floppy or CD media (in case you
  still find machines that cannot natively boot from USB).

- The USB key uses a PC (MBR) partition table and a single FAT32 formatted partition,
  to make it usable by as many devices as possible. It is also possible to move all
  files to a different disk and back later, and the USB device can still be booted.
  It is also possible to copy the files to a new USB key and re-run the installer, and
  keep all modules and menu customizations.

- The number of "core files" (files installed by the core) is minimized as far as
  possible. BIOS boot support requires 2 files (both under `/usb-modboot/` directory),
  efi boot support (including Secure Boot) requires 4 additional files (under `/efi/`
  directory). All module files are tried to be kept under these two directories, too.
  That way, your USB stick is kept neat and clean; and filesystem checks do not take
  longer than needed. There are exceptions: Windows 10 Recovery needs to have a few files
  under `/boot/`, for example.

- By default, the installer does not format your USB key or delete files from it; so you
  should be able to add usb-modboot to an existing USB key without having to back up your
  data first (unless you are using the dd-able image mentioned above).


### Supported Modules

To add modules, just copy them into `/usb-modboot/` directory. The following module types
are supported:

- Directories or `tar` files containing a `grub.cfg` file. These modules will then chainload
  this config file. Individual `.cfg` files are also valid modules, if they are not inside of
  directories or `tar` files. The variable `MODULE_PATH` can be used inside the config file
  to point back to the module (in case the user renames it).

- ISO images. If they contain a `/boot/grub/loopback.cfg`, they are bootable as is. Other .iso files
  need a companion file with same base name, named `*.iso.module.tar` or `*.iso.module.cfg`, which
  needs to be a valid module and is loaded instead of the ISO file.

- 16-bit Linux "kernel" images (`.lkrn` files or `.bin` files). Made famous by Memtest86+ and gPXE/iPXE.

- 1.44 MB floppy images (`.img` files). Woll be booted by memdisk, when in BIOS mode. Cannot be booted
  in UEFI mode.

- 64-bit EFI images (`.efi` files). Can only be booted in 64-bit UEFI mode. When 32-bit UEFI support is
  added, 32-bit EFI images (`.efi32` files) can be used as modules in that environment.

- also, for every module there can be an .ini file with same name (so for `ipxe.lkrn` it has to be called
  `ipxe.lkrn.ini`) which can contain additional options. For now, the only supported option is `LABEL=` which
  can be used to override the menu label.


## Installing usb-modboot

### Installing the core

For this, you need a USB key which contains a single partition (MBR partitioning scheme) which is formatted
with FAT32 filesystem. Most USB keys are formatted like this from the factory. When formatting it yourself
in Linux, choose partition type `0B` and don't forget to set the *bootable* flag (which is required by some
BIOSes to make the USB key appear in the boot menu).

Then, copy the content of [usb-modboot.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/usb-modboot.zip) to that USB key.
On Windows, double click `\install\bios-install.cmd` file, on Linux you can change to `install` directory and run `./bios-install.sh` if you
have grub-bios-setup installed (which will dynamically set up GRUB like on Windows), or run `./bios-install-from-bootblock.sh /dev/sdX` (which
will use some `dd` magic to put GRUB onto the MBR). Note that the latter command will need the name of the device as an argument, while the first
command (both on Windows and on Linux) will autodetect the device from where the file is stored and (after a confirmation) work automatically.

On other operating systems that support neither of the script, you can write the disk image `usb-bootblock.img.xz` (after extracting) onto an empty
USB key with at least 1GB capacity. Then you'll have to increase the partition size of the partition to fill the full USB key, and then copy the
contents on the USB key again. This is more like a last resort method; if possible I would always prefer one of the other methods.

After installation is finished, you may delete the `install` directory (or keep it in case you want to copy the files to another USB key later, for
easier re-running).


### Adding modules

Download the modules you like and copy them to `usb-modboot` directory. Modules available here are `.zip` files; they need to be extracted to the root of
the USB key (but will drop the majority of files in `usb-modboot`, too). Modules will be automatically picked up when booting, so there is no need
to edit menu files (unless you want to add the modules into the favourite modules menu).

- [module.win10recovery.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.win10recovery.zip) can be used to add
  Windows 10 Recovery (one edition or multiple ones) to the USB key. The module comes
  with [RecoveryDriveBuilderPlus](https://github.com/schierlm/RecoveryDriveBuilderPlus), which you have to use to add the recovery options to your
  USB key. After you have added them, you may delete RecoveryDriveBuilderPlus or keep it to simplify adding more recovery drives later.

- [module.efitools.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.efitools.zip) adds additional EFI tools
  (Memtest, EFI shell, and some utilities to be used in EFI shell) to the boot menu if you are booting in EFI mode.

- [module.efi32.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.efi32.zip) adds 32-bit EFI booting
  support, as well as 32-bit EFI and UEFI shells.

- [module.netboot.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.netboot.zip) contains iPXE images
  to boot from [netboot.xyz](https://netboot.xyz/) and [boot.fedoraproject.org](https://boot.fedoraproject.org/)

- [module.memtest.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.memtest.zip) contains
  Memtest86 and Memtest86+ for BIOS mode (Memtest for EFI mode is part of efitools).

- [module.super_grub2_disk.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.super_grub2_disk.zip) provides a small
  (<200KB) lite version of [Super Grub2 Disk](https://www.supergrubdisk.org/). The official Super Grub2 Disk ISO works too, but the fonts look
  a bit worse, and it is a lot bigger (not to forget the big scary warning at startup that loopback booting is not officially supported).

- [module.ubuldr.zip](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.ubuldr.zip) contains an alternative EFI loader
  that can load Ubuntu and Windows 10 with Secure Boot enabled,
  without needing to enroll any hashes. In case Secure Boot is disabled, the loader is automatically skipped. There is also
  an option to continue to the "normal" menu (which may require enrolling the hash of loader.efi). It is normal that one file
  (`bootx64.efi`) is overwritten, therefore make sure to extract this after extracting the main `.zip` file.


There are also modules that should be dropped next to an [UltimateBootCD 5.3.7 ISO](http://www.ultimatebootcd.com/) or a
[Debian 9.3.0 netinst ISO](https://www.debian.org/distrib/), to support booting from them. More modules may be added in the
future (maybe without updating this README file).


### Configuring favourite modules

When you have many modules on usb-modboot, the menu can become long and selecting may take some time. Therefore, you can add favourites which appear
in the main menu (other modules will still appear in the "All Boot Modules" menu). Therefore you edit `menu.ini` and add lines like

    addmodule ubuntu.iso

or

    addmodule ubuntu.iso "My Favourite Ubuntu"

in case you want to use a custom title. The first argument to addmodule is the filename of the file inside `/usb-modboot/` directory
(but without the directory name).

In fact, you can use all GRUB commands (including `submenu`) in this file, so you can build more complex favourite menus if you prefer.
But you don't have to - for most users, just using addmodule should be fine.


## Compiling usb-modboot from source

If you want to modify how usb-modboot works, you have to compile it from source.
If you just want to use usb-modboot, you can ignore this part.

I use a minimal Debian Stretch VM for building; it should work on other distros as well.
root privileges are required.

First you need some build tools:

    # apt install build-essential unzip gettext libfreetype6-dev dosfstools autoconf automake bison flex xfonts-unifont python ca-certificates git

Then checkout this repo:

    # git clone https://github.com/schierlm/usb-modboot

First compile grub

    # cd usb-modboot
    # ./build-grub

Then build the main core image and some more auxiliary files

    # ./build-main

The resulting files are in `dist` now. Note that this command also builds some modules;
other modules have dedicated build scripts; yet other modules do not have any build scripts
but are put together manually from other source pages.

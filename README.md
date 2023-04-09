
This project can be used to build an initramfs image for a Raspberry Pi that can be used to create a full disk backup of the rootfs before booting the actual system.

<!-- Resources and examples:
   - https://wiki.gentoo.org/wiki/Custom_Initramfs
   - https://wiki.gentoo.org/wiki/Custom_Initramfs/Examples -->

# Building the initial ram disk
The following steps are required in order to build the ram disk:
1. Compile or download a statically linked version of [BusyBox](https://www.busybox.net).
2. Copy the BusyBox executable to `rootfs/bin`.
3. Adjust the configuration file in `rootfs/etc/config`.
4. Create a `cpio` image of the `rootfs` directory.

The `build` script contains functions to automate all steps:

```sh
$ ./build getbusybox arm
$ cp ./busybox ./rootfs/bin
$ ./build package
```

Copy the built ram disk from the working directory to `/boot/initramfs.cpio` on your Raspberry Pi.

# Configuring the Raspberry Pi
In order to load and execute the ram disk during boot, add the following directive to your `/boot/config.txt`:

```
initramfs initramfs.cpio followkernel
```

# Trigger backup creation
To trigger the creation of a backup, create a `.renew` flag file on the backup target device and reboot the system.

For example, consider the following configuration setup in `rootfs/etc/config`:

```sh
BACKUP_SOURCE=DEVICE=/dev/mmcblk0                       # mounted to / (sdcard)
BACKUP_TARGET=UUID=bb57cb7a-94a8-45d2-821a-9daa2f716d9e # mounted to /mnt (UUID of external hdd)
BACKUP_FILE=backups/rootfs.img
```

Then the existence of `/mnt/backups/rootfs.img.renew` would trigger a backup on the next system (re)boot.

# Mount backup image
Once a backup image has been created use `losetup` to create a `loop` device for each partition within the image. Then use `mount` on each partition you want to access.

```sh
$ losetup --partscan --find --show rootfs.img # prints loop device name (e.g. /dev/loop0)
$ mount /dev/loop0p2 /mnt # mounts partition 2 of rootfs.img
```

To unmount the backup image do:

```sh
$ umount /mnt
$ losetup -d /dev/loop0 # cleans up loop device
```

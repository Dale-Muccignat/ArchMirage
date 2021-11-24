#!/bin/bash
# Update system clock:
timedatectl set-ntp true
# Time to partition! I know the installer recommends fdisk but I used cfdisk to create my partitions. It's graphical:
sfdisk /dev/sda < sda.sfdisk
# Go through and delete any partitions there are. There should just be free space. We are going to set up 3 partitions. You hit new and select the size, then you have to change the type.
 # 1. 1G efi filesystem: This is where the bootloader will mount to.
 # 2. 8G swarp partition: This is optional but could help with ram or something like that
 # 3. Linux filesystem: Rest of storage. this is where we will mount linux
# Once that's all done select write and then quit. You can check it with "fdisk -l".
# Now we format each partition. I'll assume you did the above in order so I'll use the /dev/sdaX accordingly. But just check the fdisk is yours is different.
# Format the linux filesystem:
mkfs.ext4 -F /dev/sda3
# Format the swap:
mkswap /dev/sda2
# Format the EFI filesystem
mkfs.fat -F 32 /dev/sda1
# Now we want to mount the filesystem (so linux knows where to install)
# Mount the filesystem:
mount /dev/sda3 /mnt
# Woo, almost there. Now we just make sure the mirror list is updated by running:
reflector
# Now we install essential shit
pacstrap /mnt base linux linux-firmware
# Notice how it'll detect where to install through the mount point /mnt. I also installed networkmanager and vim for internet and text editing. 
# Now we write down the partition table of fstab for linux to read
genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt/chroot.sh

# And now we can chroot into linux!
arch-chroot /mnt /bin/bash chroot.sh

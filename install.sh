#!/bin/bash
# Update keyring, don't know why this is needed now
pacman -Sy archlinux-keyring
# Update system clock:
timedatectl set-ntp true
# Time to partition! I know the installer recommends fdisk but I used cfdisk to create my partitions. It's graphical:
x="================================================================="
echo $x
lsblk --output NAME,TYPE,SIZE,MODEL,SERIAL | grep 'disk'
echo $x
y=$(lsblk --output NAME,TYPE,SIZE,MODEL,SERIAL | grep 'disk' | cut -d" " -f1 | tr '\n' '/')
read -p "Select one of [${y%?}]: " drive
sfdisk "/dev/${drive}" < sda.sfdisk
# We are going to set up 3 partitions. You hit new and select the size, then you have to change the type.
 # 1. 1G efi filesystem: This is where the bootloader will mount to.
 # 2. 8G swarp partition: This is optional but could help with ram or something like that
 # 3. Linux filesystem: Rest of storage. this is where we will mount linux

 # TODO: add nvme support
if [[ ${drive} = *"sd"* ]]
then
    ## If sd
    # Format the linux filesystem:
    mkfs.ext4 -F "/dev/${drive}3"
    # Format the swap:
    mkswap "/dev/${drive}2"
    # Format the EFI filesystem
    mkfs.fat -F 32 "/dev/${drive}1"

    # Now we want to mount the filesystem (so linux knows where to install)
    # Mount the filesystem:
    mount "/dev/${drive}3" /mnt
elif [[ ${drive} = *"nv"* ]]
then
    ## if nvm
    # Format the linux filesystem:
    mkfs.ext4 -F "/dev/${drive}p3"
    # Format the swap:
    mkswap "/dev/${drive}p2"
    # Format the EFI filesystem
    mkfs.fat -F 32 "/dev/${drive}p1"

    # Now we want to mount the filesystem (so linux knows where to install)
    # Mount the filesystem:
    mount "/dev/${drive}p3" /mnt
fi

# Woo, almost there. Now we just make sure the mirror list is updated by running:
#reflector
# Now we install essentials 
pacstrap /mnt base linux linux-firmware
# Now we write down the partition table of fstab for linux to read
genfstab -U /mnt >> /mnt/etc/fstab

# copy files for chroot access
cp -R ../ArchMirage /mnt

# save drive info
echo "drive=$drive" >> /mnt/ArchMirage/install.conf

# And now we can chroot into linux!
arch-chroot /mnt /bin/bash ArchMirage/chroot.sh
source /mnt/root/ArchMirage/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchMirage/user.sh

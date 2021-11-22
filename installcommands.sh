#!/bin/bash
# I had to install via wireless so first using iwctl to connect:
iwctl
# Get name of the adaptor:
device list
# In the following, replace "device" with the name of it. For me it was wlan0. SSID as in the name of the network.
station device connect SSID
# Ctrl+D to exit iwctl.
# Update system clock:
timedatectl set-ntp true
# Time to partition! I know the installer recommends fdisk but I used cfdisk to create my partitions. It's graphical:
cfdisk
# Go through and delete any partitions there are. There should just be free space. We are going to set up 3 partitions. You hit new and select the size, then you have to change the type.
 # 1. 1G efi filesystem: This is where the bootloader will mount to.
 # 2. 8G swarp partition: This is optional but could help with ram or something like that
 # 3. Linux filesystem: Rest of storage. this is where we will mount linux
# Once that's all done select write and then quit. You can check it with "fdisk -l".
# Now we format each partition. I'll assume you did the above in order so I'll use the /dev/sdaX accordingly. But just check the fdisk is yours is different.
# Format the linux filesystem:
mkfs.ext4 /dev/sda3
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
pacstrap /mnt base linux linux-firmware networkmanager vim alacritty git base-devel
# Notice how it'll detect where to install through the mount point /mnt. I also installed networkmanager and vim for internet and text editing. 
# Now we write down the partition table of fstab for linux to read
genfstab -U /mnt >> /mnt/etc/fstab
# And now we can chroot into linux!
arch-chroot /mnt
# Set the timezone
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
# Run hwclock to make sure local/system time and good
hwclock --systohc
# Now the fun edit file part. I use vim here but maybe use a different text editor haha
# Edit /etc/local.gen and uncomment en_US.UTF-8 UTF-8
vim /etc/locale.gen
# Use j/k to go up down until you find the line. Move curse to the # on that line and hit "x" to delete it. Type ":wq" to save and quit.
# Generate the locales (idek what this is doing but it's some weird filesystem thing)
locale-gen
# Edit /etc/locale.conf
vim /etc/locale.conf
# hit "i" to enter edit mode and type "LANG=en_US.UTF-8". hit "esc" to exit edit mode and then type ":wq" to save and quit.
# Make a root password
passwd
# Time for bootloaded. I got this from the GRUB page of archwiki. Install grub and efibootmgr:
pacman -S grub efibootmgr
# then install grub to a mount point:
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
# then generate the GRUB config file
grub-mkconfig -o /boot/grub/grub.cfg

# At this point you can restart and log into root just fine but lets set up our display manager and desktop environment.
# So display manager handles the log in and handles the overal "display" and the you log into a desktop envionment from the display manager.
# There's a few display managers to choose from but I'm going to use GDM - IDK if it's the best choice tbh but who cares.
pacman -S gdm cinnamon
# Just select the default option.
# Now we need to enable gdm so that it starts on startup through
systemctl enable gdm.service
# Might aswell enable networkmanager here aswell
systemctl enable NetworkManager.service
# Then just add a user:
useradd -m dale
passwd dale
# And just need to set up the "sudo" shit
pacman -S sudo
# then edit /etc/sudoers and add "dale ALL=(ALL) ALL" under the user alias specification section
visudo /etc/sudoers
# use j/k to move to under the user alias section. Hit "i" to enter edit mode. Type out the line then hit "esc" to exit edit mode. Then type ":wq" to write and quit.
# Now we can ctrl+d to exit chroot and then reboot and remove the usb. 
# SAVE THE USB, you can use it to save your computer if it dies. You can chroot into 
# PRO TIPS: 
# Edit /etc/pacman.conf to enable parralel downloads (I'd say like 6)
# install "tldr" so that you can go "tldr zip" or some shit when you don't know how to use a command/program.


# Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

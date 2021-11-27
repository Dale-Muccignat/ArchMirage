#!/bin/bash
# Set the timezone
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
# Run hwclock to make sure local/system time and good
hwclock --systohc
# Now the fun edit file part. I use vim here but maybe use a different text editor haha
# Edit /etc/local.gen and uncomment en_US.UTF-8 UTF-8
#vim /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
# Add parallelDownloads
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
# Use j/k to go up down until you find the line. Move curse to the # on that line and hit "x" to delete it. Type ":wq" to save and quit.
# Generate the locales (idek what this is doing but it's some weird filesystem thing)
locale-gen
# Edit /etc/locale.conf
#vim /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# hit "i" to enter edit mode and type "LANG=en_US.UTF-8". hit "esc" to exit edit mode and then type ":wq" to save and quit.
# Time for bootloaded. I got this from the GRUB page of archwiki. Install grub and efibootmgr:
pacman -S --noconfirm grub efibootmgr gdm cinnamon i3-gaps i3status i3blocks sudo networkmanager vim alacritty git base-devel
# then install grub to a mount point:
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
# then generate the GRUB config file
grub-mkconfig -o /boot/grub/grub.cfg

# At this point you can restart and log into root just fine but lets set up our display manager and desktop environment.
# So display manager handles the log in and handles the overal "display" and the you log into a desktop envionment from the display manager.
# There's a few display managers to choose from but I'm going to use GDM - IDK if it's the best choice tbh but who cares.
# pacman -S 
# Just select the default option.
# Now we need to enable gdm so that it starts on startup through
systemctl enable gdm.service
# Might aswell enable networkmanager here aswell
systemctl enable NetworkManager.service
# Make a root password
echo Password for root
passwd
# Then just add a user:
read -p "Name for user profile: " username
useradd -m $username
passwd $username

echo Password for user $username
echo "username=$username" >> ${HOME}/ArchMirage/install.conf
cp -R /root/ArchMirage /home/$username
chown -R $username: /home/$username/ArchMirage
chmod -R u=rwx /home/$username/ArchMirage
# And just need to set up the "sudo" shit
# pacman -S sudo
# then edit /etc/sudoers and add "dale ALL=(ALL) ALL" under the user alias specification section
#visudo /etc/sudoers
echo "$username ALL=(ALL) ALL" >> /etc/sudoers
# use j/k to move to under the user alias section. Hit "i" to enter edit mode. Type out the line then hit "esc" to exit edit mode. Then type ":wq" to write and quit.
# Now we can ctrl+d to exit chroot and then reboot and remove the usb. 
# SAVE THE USB, you can use it to save your computer if it dies. You can chroot into 
# PRO TIPS: 
# Edit /etc/pacman.conf to enable parralel downloads (I'd say like 6)
# install "tldr" so that you can go "tldr zip" or some shit when you don't know how to use a command/program.


# Install yay
#git clone https://aur.archlinux.org/yay.git
#cd yay
#makepkg -si --noconfirm
#cd ..

exit # to leave the chroot

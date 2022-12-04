#!/bin/bash
source /ArchMirage/install.conf

# Set the timezone
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
# Run hwclock to make sure local/system time and good
hwclock --systohc
# Edit /etc/local.gen and uncomment en_US.UTF-8 UTF-8
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
# Add parallelDownloads
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
# Generate the locales (idek what this is doing but it's some weird filesystem thing)
locale-gen
# Edit /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Time for bootloader. I got this from the GRUB page of archwiki. Install grub and efibootmgr:
pacman -S --noconfirm grub efibootmgr sddm cinnamon i3-wm i3status i3blocks sudo networkmanager vim alacritty git base-devel intel-ucode

# then install grub to a mount point:
mkdir /mnt/boot
if [[ ${drive} = *"sd"* ]] || [[ ${drive} = *"vd"* ]]
then
    mount "/dev/${drive}1" /mnt/boot
elif [[ ${drive} = *"nv"* ]] || [[ ${drive} = *"mmc"* ]] || [[ ${drive} = *"loop"* ]]
then
    mount "/dev/${drive}p1" /mnt/boot
fi

grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
# then generate the GRUB config file
grub-mkconfig -o /boot/grub/grub.cfg

# Now we need to enable gdm so that it starts on startup through
systemctl enable sddm.service
# Might aswell enable networkmanager here aswell
systemctl enable NetworkManager.service

# Make a root password
echo Password for root
passwd
# Then just add a user:
read -p "Name for user profile: " username
useradd -m $username
passwd $username

cp -R ArchMirage /root
cp -R /root/ArchMirage /home/$username
chown -R $username: /home/$username/ArchMirage
chmod -R u=rwx /home/$username/ArchMirage
echo "username=$username" >> ${HOME}/ArchMirage/install.conf

# Add user as a sudoer
echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers


exit # to leave the chroot

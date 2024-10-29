#!/bin/bash
function choose_from_menu() {
  local prompt="$1" outvar="$2" pacnames="$3"
  shift
  shift
  shift
  local options=("$@") cur=0 count=${#options[@]} index=0
  local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
  printf "$prompt\n"
  while true; do
    # list all options (option list is zero-based)
    index=0
    for o in "${options[@]}"; do
      if [ "$index" == "$cur" ]; then
        echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
      else
        echo "  $o"
      fi
      ((index++))
    done
    read -s -n3 key               # wait for user to key in arrows or ENTER
    if [[ $key == $esc[A ]]; then # up arrow
      ((cur--))
      ((cur < 0)) && ((cur = 0))
    elif [[ $key == $esc[B ]]; then # down arrow
      ((cur++))
      ((cur >= count)) && ((cur = count - 1))
    elif [[ $key == "" ]]; then # nothing, i.e the read delimiter - ENTER
      break
    fi
    echo -en "\e[${count}A" # go up to the beginning to re-render
  done
  # export the selection to the requested output variable
  printf -v $outvar "${pacnames[$cur]}"
}

# Update keyring, don't know why this is needed now
pacman -Sy --noconfirm archlinux-keyring
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

# Ask for DMs to install
# taken from Guss at https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script


DMs=("Plasma" "Gnome" "i3")
DMs_pacnames=("plasma-meta" "gnome" "i3-wm")
choose_from_menu "Choose a display manager to install:" selected_DM DMs_pacnames "${DMs[@]}"
echo "Selected display manager: $selected_DM"

# Define partition names properly
# sd/vd are named with just the number
# nvmeXnX, mmcbXkX and loopX are named with pX
if [[ ${drive} = *"sd"* ]] || [[ ${drive} = *"vd"* ]]
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
elif [[ ${drive} = *"nv"* ]] || [[ ${drive} = *"mmc"* ]] || [[ ${drive} = *"loop"* ]]
then
    ## if nvm, mmc or loop
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
echo "selected_DM=$selected_DM" >> /mnt/ArchMirage/install.conf

# And now we can chroot into linux!
arch-chroot /mnt /bin/bash ArchMirage/chroot.sh
source /mnt/root/ArchMirage/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchMirage/user.sh

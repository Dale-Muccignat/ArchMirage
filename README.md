# ArchMirage

Yet another installer script for archlinux customized to the Mirage ways.

# Install Instructions

## Prepare install medium

Download and prepare an ArchLinux installation disk (typically a USB) according to the the [ArchLinux Installation Guide](https://wiki.archlinux.org/title/installation_guide).

## Connect to the internet

Connect to Ethernet/Wifi. Ethernet should by default be connected. For Wifi use the `iwctl` package.
Find your Wifi adaptor name:
```
iwctl station list
```
Find your wifi adaptor name within the device list. This will be refered to as "device" in what follows. Find your Wifi network:
```
iwctl station device scan
iwctl station device get-networks
```
Connect to your network by it's name (SSID):
```
iwctl station device connect SSID
```
Type in your password to connect to the network. For more information see [iwd](https://wiki.archlinux.org/title/Iwd).

## Download and run the installer script

First, update the package database of ArchLinux and install `git`:
```
pacman -Sy git
```
Then clone this repository:
```
git clone https://github.com/Dale-Muccignat/ArchMirage.git
```
Change directory to `ArchMirage`:
```
cd ArchMirage
```
Finally, run the installer script provided:
```
bash install.sh
```

# Goals
- Select which DE and WM
- Custom inputs in partition table
- Set up config files for each supported WM

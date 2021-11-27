#!/bin/bash
cd ~
git clone https://aur.archlinux.org/yay.git
cd ${HOME}/yay
makepkg -si --noconfirm

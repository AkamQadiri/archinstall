#!/bin/sh

#Cd into directory and start the script with:
#source install.sh

#System
export HOSTNAME="archtop"
export LANGUAGE="en_US.UTF-8"
export KEYBOARD="no"
export TIMEZONE="Europe/Oslo"

#User
export USER_NAME="akam"
export USER_PASSWORD="secret"
export USER_GROUPS="wheel,uucp"

#Device (lsblk to check)
export DEVICE="/dev/nvme0n1"
export EFI_PARTITION="$DEVICE"p1
export ROOT_PARTITION="$DEVICE"p2

#Packages
export X_PACKAGES="xorg xorg-xinit xorg-apps xdg-utils picom"
export DRIVER_PACKAGES="intel-ucode libva-intel-driver vulkan-intel xf86-video-nouveau libva-mesa-driver mesa mesa-utils"
export AUDIO_PACKAGES="pipewire pipewire-alsa pipewire-pulse pipewire-jack"
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-font-awesome"
export ADDITIONAL_PACKAGES="git vim htop firefox feh python-pywal"

#YAY Packages will only be installed if git is present
export YAY_PACKAGES="pfetch nsxiv nnn-icons" 

#Systemctl services
export SYSTEMCTL_GLOBAL_SERVICES="pipewire pipewire-media-session pipewire-pulse"

#Git settings (Only if ADDITIONAL_PACKAGES contains git package)
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"

#Set the console keyboard layout
loadkeys $KEYBOARD

#Update the system clock
timedatectl set-ntp true

#Partition the disks
sfdisk $DEVICE < disk.sfdisk

./arch_live.sh

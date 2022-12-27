#!/bin/sh

#Cd into directory and start the script with:
#source install.sh

#System
export HOSTNAME="archtop"
export LANGUAGE="en_US.UTF-8"
export KEYBOARD="no"
export TIMEZONE="Europe/Oslo"
export PARALLELDOWNLOADS="15"

#User
export USER_NAME="akam"
export USER_PASSWORD="secret"
export USER_GROUPS="wheel,uucp"

#Device (lsblk to check)
export DEVICE="/dev/nvme0n1"
export EFI_PARTITION="$DEVICE"p1
export ROOT_PARTITION="$DEVICE"p2

#Packages
export X_PACKAGES="xorg xorg-xinit xorg-apps xdg-utils numlockx xdotool perl-file-mimeinfo picom lxsession-gtk3 unclutter"
export DRIVER_PACKAGES="intel-ucode mesa mesa-utils libva-mesa-driver libva-vdpau-driver libva-intel-driver vulkan-icd-loader vulkan-intel nvidia nvidia-utils"
export AUDIO_PACKAGES="pipewire pipewire-alsa pipewire-pulse pipewire-jack noise-suppression-for-voice pavucontrol"
export FONT_PACKAGES="ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-font-awesome"
export ADDITIONAL_PACKAGES="zip unzip git vim htop firefox feh python-pywal playerctl"

#YAY Packages will only be installed if git is present
export YAY_PACKAGES="pfetch nnn-icons czkawka-gui-bin" 

#Systemctl services
export SYSTEMCTL_GLOBAL_SERVICES="pipewire pipewire-media-session pipewire-pulse"

#Git settings (Only if ADDITIONAL_PACKAGES contains git package)
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"

./arch_live.sh

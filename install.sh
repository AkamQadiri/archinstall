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
#The partition naming conventions may vary based on your drive type.
#NVME drives use p1, p2, p3 ... etc
export DEVICE="/dev/nvme0n1"
export EFI_PARTITION="$DEVICE"p1
export ROOT_PARTITION="$DEVICE"p2

#Packages
export X_PACKAGES="xorg xorg-xinit xorg-apps xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk rtkit numlockx xdotool perl-file-mimeinfo picom lxsession-gtk3 unclutter"
export DRIVER_PACKAGES="amd-ucode mesa mesa-utils libva-mesa-driver mesa-vdpau libva-vdpau-driver vulkan-icd-loader vulkan-radeon"
export AUDIO_PACKAGES="pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol"
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-dejavu ttf-liberation ttf-hack ttf-font-awesome"
export ADDITIONAL_PACKAGES="zip unzip git vim htop firefox feh python-pywal playerctl"
#Uncomment the line below to install and configure libvirt (Adds the user to libvirt group automatically)
#export LIBVIRT_PACKAGES="qemu-desktop dnsmasq dmidecode bridge-utils openbsd-netcat virt-manager swtpm libguestfs"

#Comment out the line below if you don't want to install yay or any packages from the AUR (git needs to be present as it's needed to download and install yay)
export YAY_PACKAGES="pfetch nnn-icons czkawka-gui-bin" 

#Systemctl services
export SYSTEMCTL_GLOBAL_SERVICES="pipewire.service pipewire-pulse.service wireplumber.service"

#Git settings (These settings will only be used if git is present)
#Install GITHUB_REPOSITORIES and GITHUB_DOTFILES_REPOSITORY from GitHub with the help of GIT_NAME
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"
export GITHUB_REPOSITORIES="dwm dwmblocks-async st dmenu slock" #A MAKEFILE is needed for each repository
export GITHUB_DOTFILES_REPOSITORY="dotfiles" #Have install.sh in the top level directory of the repository

./arch_live.sh

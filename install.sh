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
export X_PACKAGES="xdg-desktop-portal xdg-desktop-portal-gtk xdg-utils gnome-keyring lxsession-gtk3 numlockx perl-file-mimeinfo picom rtkit unclutter xdotool xorg xorg-apps xorg-xinit"
export DRIVER_PACKAGES="amd-ucode libva-mesa-driver libva-vdpau-driver mesa mesa-utils mesa-vdpau vulkan-icd-loader vulkan-radeon"
export AUDIO_PACKAGES="pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber"
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-dejavu ttf-font-awesome ttf-hack ttf-liberation"
export ADDITIONAL_PACKAGES="hdparm feh firefox git git-lfs htop playerctl python-pywal unzip vim zip"
#Uncomment the line below to install and configure libvirt (Adds the user to libvirt group automatically)
#export LIBVIRT_PACKAGES="bridge-utils dnsmasq dmidecode libguestfs openbsd-netcat qemu-desktop swtpm virt-manager"

#Comment out the line below if you don't want to install yay or any packages from the AUR (git needs to be present as it's needed to download and install yay)
export YAY_PACKAGES="czkawka-gui-bin nnn-icons pfetch"

#Systemctl services
export SYSTEMCTL_GLOBAL_SERVICES="pipewire.service pipewire-pulse.service wireplumber.service"

#Git settings (These settings will only be used if git is present)
#Install GITHUB_REPOSITORIES and GITHUB_DOTFILES_REPOSITORY from GitHub with the help of GIT_NAME
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"
export GITHUB_REPOSITORIES="dwm dwmblocks-async st dmenu slock" #A MAKEFILE is needed for each repository
export GITHUB_DOTFILES_REPOSITORY="dotfiles" #Have install.sh in the top level directory of the repository

./arch_live.sh

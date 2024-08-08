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
export X_PACKAGES="gnome-keyring lxsession-gtk3 numlockx perl-file-mimeinfo picom rtkit unclutter xdg-desktop-portal xdg-desktop-portal-gtk xdg-utils xdotool xorg xorg-apps xorg-xinit"
#Comment out the line below if you don't use a AMD CPU or GPU
export AMD_DRIVER_PACKAGES="amd-ucode vulkan-radeon"
#Comment out the line below if you don't use a NVIDIA GPU
export NVIDIA_DRIVER_PACKAGES="nvidia nvidia-utils"
export DRIVER_PACKAGES="libva-mesa-driver libva-vdpau-driver mesa mesa-utils mesa-vdpau vulkan-icd-loader $AMD_DRIVER_PACKAGES $NVIDIA_DRIVER_PACKAGES"
export AUDIO_PACKAGES="pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber"
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-dejavu ttf-font-awesome ttf-hack ttf-liberation"
export ADDITIONAL_PACKAGES="feh firefox git git-lfs hdparm htop jq mpv playerctl python-pywal unzip vim zip"
#Uncomment the line below to install and configure libvirt (Adds the user to libvirt group automatically)
#export LIBVIRT_PACKAGES="bridge-utils dmidecode dnsmasq libguestfs openbsd-netcat qemu-desktop swtpm virt-manager"

#Add qemu-guest-agent to ADDITIONAL_PACKAGES if machine is a VM
if grep -qE 'vmx|svm' /proc/cpuinfo; then
    export ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES qemu-guest-agent"
fi

#iperf3 and sysbench is for hardinfo2
#libheif is for czkawka-gui-bin
#nsxiv is for nnn-icons
export AUR_DEPENDENCIES="iperf3 libheif nsxiv sysbench"
#Comment out the line below if you don't want to install yay, any packages from the AUR or AUR_DEPENDENCIES (git needs to be present as it's needed to download and install yay)
export YAY_PACKAGES="czkawka-gui-bin hardinfo2 nnn-icons pfetch"

#Systemctl services
export SYSTEMCTL_GLOBAL_SERVICES="pipewire.service pipewire-pulse.service wireplumber.service"

#Git settings (These settings will only be used if git is present)
#Install GITHUB_REPOSITORIES and GITHUB_DOTFILES_REPOSITORY from GitHub with the help of GIT_NAME
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"
export GITHUB_REPOSITORIES="dwm dwmblocks-async st dmenu tabbed slock hyperx-cloud-flight" #A MAKEFILE is needed for each repository
export GITHUB_DOTFILES_REPOSITORY="dotfiles" #Have install.sh in the top level directory of the repository

./arch_live.sh

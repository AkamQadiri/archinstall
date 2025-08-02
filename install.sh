#!/bin/bash

# Arch Linux installation configuration
# Run with: source install.sh

# === SYSTEM CONFIGURATION ===
export HOSTNAME="archtop"
export LANGUAGE="en_US.UTF-8"
export KEYBOARD="no"
export TIMEZONE="Europe/Oslo"
export PARALLELDOWNLOADS="15"

# === STORAGE CONFIGURATION ===
# Run 'lsblk' to identify your drive
# NVMe drives use p1, p2 format; SATA/SAS use 1, 2 format
export DEVICE="/dev/nvme0n1"
export EFI_PARTITION="${DEVICE}p1"
export ROOT_PARTITION="${DEVICE}p2"

# === USER CONFIGURATION ===
export USER_NAME="akam"
export USER_PASSWORD="secret"
export USER_GROUPS="wheel,uucp"

# === HARDWARE DETECTION ===
# Detect Intel CPU for microcode
if grep -q "GenuineIntel" /proc/cpuinfo; then
    export INTEL_CPU_PACKAGES="intel-ucode"
fi

# Detect Intel GPU for VA-API and Vulkan driver
if lspci | grep -E "VGA|3D" | grep -qi "Intel"; then
    export INTEL_GPU_PACKAGES="intel-media-driver vulkan-intel"
fi

# Detect AMD CPU for microcode
if grep -q "AuthenticAMD" /proc/cpuinfo; then
    export AMD_CPU_PACKAGES="amd-ucode"
fi

# Detect AMD GPU for VDPAU and Vulkan driver
if lspci | grep -E "VGA|3D" | grep -qi "AMD\|ATI"; then
    export AMD_GPU_PACKAGES="mesa-vdpau vulkan-radeon"
fi

# Detect NVIDIA GPU
if lspci | grep -E "VGA|3D" | grep -qi "NVIDIA"; then
    export NVIDIA_DRIVER_PACKAGES="nvidia nvidia-utils"
fi

# Combine Driver packages
export INTEL_DRIVER_PACKAGES="${INTEL_CPU_PACKAGES} ${INTEL_GPU_PACKAGES}"
export AMD_DRIVER_PACKAGES="${AMD_CPU_PACKAGES} ${AMD_GPU_PACKAGES}"

# === PACKAGE DEFINITIONS ===
# X11 and desktop environment components
export X_PACKAGES="dunst gnome-keyring i3blocks i3-wm libnotify lxsession-gtk3 numlockx perl-file-mimeinfo picom rofi rtkit unclutter xdg-desktop-portal xdg-desktop-portal-gtk xdg-utils xdotool xorg xorg-apps xorg-xinit"

# Graphics drivers (combines detected hardware packages)
export DRIVER_PACKAGES="libva-mesa-driver mesa mesa-utils vulkan-icd-loader ${INTEL_DRIVER_PACKAGES} ${AMD_DRIVER_PACKAGES} ${NVIDIA_DRIVER_PACKAGES}"

# Audio stack (PipeWire)
export AUDIO_PACKAGES="pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber"

# Font packages for proper text rendering
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"

# Essential utilities
export ADDITIONAL_PACKAGES="fd feh firefox flameshot ghostty git git-lfs htop jq mpv neovim npm playerctl ripgrep unzip zip"

# Virtual machine guest additions (auto-detected)
if systemd-detect-virt -q; then
    export ADDITIONAL_PACKAGES="${ADDITIONAL_PACKAGES} qemu-guest-agent"
fi

# Optional: Virtualization host packages (uncomment to enable)
#export LIBVIRT_PACKAGES="bridge-utils dmidecode dnsmasq libguestfs openbsd-netcat qemu-desktop swtpm virt-manager"

# === AUR CONFIGURATION ===
# Dependencies for AUR packages (specify which package needs what)
# Example: iperf3, sysbench → hardinfo2; libheif → czkawka-gui-bin
export AUR_DEPENDENCIES=""

# AUR packages to install (requires git)
export AUR_PACKAGES="ttf-font-awesome-5"

# === SERVICE CONFIGURATION ===
# User services to enable globally
export SYSTEMCTL_GLOBAL_SERVICES="pipewire.service pipewire-pulse.service wireplumber.service"

# === GIT CONFIGURATION ===
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="AkamQadiri"
export GITHUB_REPOSITORIES="hyperx-cloud-flight" # Requires MAKEFILE in each repo
export GITHUB_DOTFILES_REPOSITORY="dotfiles"     # Must contain install.sh

# Execute installation
./arch_live.sh

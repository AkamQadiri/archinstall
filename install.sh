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
export DEVICE="/dev/nvme0n1"

# Detect partition naming scheme based on device type
if [[ "${DEVICE}" =~ ^/dev/(nvme|mmcblk|loop) ]]; then
    export EFI_PARTITION="${DEVICE}p1"
    export ROOT_PARTITION="${DEVICE}p2"
else
    export EFI_PARTITION="${DEVICE}1"
    export ROOT_PARTITION="${DEVICE}2"
fi

# Swapfile size (matches RAM so hibernation fits)
SWAP_SIZE="$(awk '/MemTotal/ {print int(($2 + 1048575) / 1048576)}' /proc/meminfo)G"
export SWAP_SIZE

# === USER CONFIGURATION ===
export USER_NAME="akam"
export USER_PASSWORD="secret"
export USER_GROUPS="wheel,uucp"

# === HARDWARE DETECTION ===
# Detect Intel CPU for microcode (skip in VMs)
if grep -q "GenuineIntel" /proc/cpuinfo && ! systemd-detect-virt -q; then
    export INTEL_CPU_PACKAGES="intel-ucode"
fi

# Detect Intel GPU for VA-API and Vulkan driver
if lspci | grep -E "VGA|3D" | grep -qi "Intel"; then
    export INTEL_GPU_PACKAGES="intel-media-driver vulkan-intel"
fi

# Detect AMD CPU for microcode (skip in VMs)
if grep -q "AuthenticAMD" /proc/cpuinfo && ! systemd-detect-virt -q; then
    export AMD_CPU_PACKAGES="amd-ucode"
fi

# Detect AMD GPU for Vulkan driver
if lspci | grep -E "VGA|3D" | grep -qi "AMD\|ATI"; then
    export AMD_GPU_PACKAGES="vulkan-radeon"
fi

# Detect NVIDIA GPU
if lspci | grep -E "VGA|3D" | grep -qi "NVIDIA"; then
    export NVIDIA_DRIVER_PACKAGES="nvidia-open nvidia-utils"
fi

# Detect laptop (battery present) for power management, audio firmware and display profiles
if find /sys/class/power_supply/ -name "BAT*" | grep -q .; then
    export LAPTOP_PACKAGES="autorandr brightnessctl sof-firmware tlp upower"
    export LAPTOP_SERVICES="autorandr.service autorandr-lid-listener.service tlp.service upower.service"

    # Intel laptops also get the thermal daemon
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        export LAPTOP_PACKAGES="${LAPTOP_PACKAGES} thermald"
        export LAPTOP_SERVICES="${LAPTOP_SERVICES} thermald.service"
    fi
fi

# Combine Driver packages
export INTEL_DRIVER_PACKAGES="${INTEL_CPU_PACKAGES} ${INTEL_GPU_PACKAGES}"
export AMD_DRIVER_PACKAGES="${AMD_CPU_PACKAGES} ${AMD_GPU_PACKAGES}"

# === PACKAGE DEFINITIONS ===
# X11 and desktop environment components
export X_PACKAGES="dunst gnome-keyring i3blocks i3lock i3-wm libnotify lxsession numlockx perl-file-mimeinfo picom rofi rofi-calc rofi-emoji rtkit unclutter xdg-desktop-portal xdg-desktop-portal-gtk xdg-utils xdotool xorg xorg-apps xorg-xinit xss-lock"

# Graphics drivers (combines detected hardware packages)
export DRIVER_PACKAGES="mesa mesa-utils vulkan-icd-loader ${INTEL_DRIVER_PACKAGES} ${AMD_DRIVER_PACKAGES} ${NVIDIA_DRIVER_PACKAGES}"

# Audio stack (PipeWire)
export AUDIO_PACKAGES="pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber"

# Bluetooth stack
export BLUETOOTH_PACKAGES="bluez bluez-utils"

# Font packages for proper text rendering
export FONT_PACKAGES="noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra"

# Essential utilities
export ADDITIONAL_PACKAGES="chafa fd feh firefox flameshot fzf ghostty git git-lfs github-cli htop jq mpv neovim nnn npm playerctl ripgrep rsync tree-sitter-cli udiskie unzip zip"

# Virtual machine guest additions (auto-detected)
if systemd-detect-virt -q; then
    export ADDITIONAL_PACKAGES="${ADDITIONAL_PACKAGES} qemu-guest-agent"
fi

# Optional: Virtualization host packages (uncomment to enable)
#export LIBVIRT_PACKAGES="dmidecode dnsmasq libguestfs openbsd-netcat qemu-desktop swtpm virt-manager"

# === AUR CONFIGURATION ===
# Dependencies for AUR packages (specify which package needs what)
# Example: iperf3, sysbench → hardinfo2; libheif → czkawka-gui-bin
export AUR_DEPENDENCIES=""

# AUR packages to install (requires git)
export AUR_PACKAGES="ttf-font-awesome-5"

# === SERVICE CONFIGURATION ===
# System services to enable (combines detected hardware services)
export SYSTEMCTL_SERVICES="bluetooth.service NetworkManager.service ${LAPTOP_SERVICES}"

# User services to enable globally
export SYSTEMCTL_GLOBAL_SERVICES="pipewire.service pipewire-pulse.service wireplumber.service"

# === GIT CONFIGURATION ===
export GIT_EMAIL="akamq@hotmail.com"
export GIT_NAME="Akam Qadiri"
export GITHUB_REPOSITORIES=""                           # Space-separated owner/repo, requires MAKEFILE in each repo
export GITHUB_DOTFILES_REPOSITORY="AkamQadiri/dotfiles" # As owner/repo, must contain install.sh

# Execute installation
./arch_live.sh

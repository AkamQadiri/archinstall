#!/bin/bash
set -euo pipefail

# Arch Linux live environment installation script
# Executes partitioning, filesystem creation, and base system installation

# === LOGGING SETUP ===
exec &> >(tee -a archinstall.log)

# === KEYBOARD CONFIGURATION ===
loadkeys "${KEYBOARD}"

# === TIME SYNCHRONIZATION ===
timedatectl set-ntp true

# === DISK PARTITIONING ===
# WARNING: This will destroy all data on ${DEVICE}
echo "Partitioning disk ${DEVICE}..."
sfdisk "${DEVICE}" <disk.sfdisk

# === KEYRING UPDATE ===
# Update keyring to prevent GPG errors
pacman --noconfirm -Sy archlinux-keyring

# === PACMAN CONFIGURATION ===
sed -i "s/#ParallelDownloads.*/ParallelDownloads = ${PARALLELDOWNLOADS}/" /etc/pacman.conf

# === FILESYSTEM CREATION ===
echo "Creating filesystems..."
mkfs.fat -F 32 "${EFI_PARTITION}"
mkfs.ext4 -F "${ROOT_PARTITION}"

# === MOUNT FILESYSTEM ===
mount "${ROOT_PARTITION}" /mnt

# === BASE SYSTEM INSTALLATION ===
echo "Installing base system..."
pacstrap /mnt base base-devel linux linux-headers linux-firmware dkms

# === FILESYSTEM TABLE ===
genfstab -U /mnt >>/mnt/etc/fstab

# === CHROOT EXECUTION ===
cp arch_chroot.sh /mnt/root/arch_chroot.sh
arch-chroot /mnt /root/arch_chroot.sh

# === CLEANUP ===
mv archinstall.log /mnt/var/log/archinstall.log
rm /mnt/root/arch_chroot.sh
umount -R /mnt

echo "Arch Linux installed successfully! You may reboot now."

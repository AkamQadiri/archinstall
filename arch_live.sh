#!/bin/bash
set -euo pipefail

# Arch Linux live environment installation script
# Executes partitioning, filesystem creation, and base system installation

# === LOGGING SETUP ===
# Keep the terminal on fds 3 and 4 so logging can be stopped before the log is moved
exec 3>&1 4>&2
exec &> >(tee -a archinstall.log)
TEE_PID=$!

# === CLEANUP ON FAILURE ===
# Unmount the target on any exit, so a failed install can be re-run without
# sfdisk finding the disk in use
trap 'mountpoint -q /mnt && umount -R /mnt' EXIT

# === KEYBOARD CONFIGURATION ===
loadkeys "${KEYBOARD}"

# === TIME SYNCHRONIZATION ===
timedatectl set-ntp true

# === DISK PARTITIONING ===
# WARNING: This will destroy all data on ${DEVICE}
echo "Partitioning disk ${DEVICE}..."
sfdisk "${DEVICE}" <disk.sfdisk

# === PACMAN CONFIGURATION ===
# Before the first download, so the keyring and pacstrap both use it
sed -i "s/^#\?ParallelDownloads.*/ParallelDownloads = ${PARALLELDOWNLOADS}/" /etc/pacman.conf

# === KEYRING UPDATE ===
# Update keyring to prevent GPG errors
pacman --noconfirm -Sy archlinux-keyring

# === FILESYSTEM CREATION ===
echo "Creating filesystems..."
mkfs.fat -F 32 "${EFI_PARTITION}"
mkfs.ext4 -F "${ROOT_PARTITION}"

# === MOUNT FILESYSTEM ===
mount "${ROOT_PARTITION}" /mnt

# === BASE SYSTEM INSTALLATION ===
echo "Installing base system..."
pacstrap /mnt base base-devel linux linux-headers linux-firmware dkms e2fsprogs

# === FILESYSTEM TABLE ===
genfstab -U /mnt >>/mnt/etc/fstab

# === CHROOT EXECUTION ===
cp arch_chroot.sh /mnt/root/arch_chroot.sh
arch-chroot /mnt /root/arch_chroot.sh

# === CLEANUP ===
rm /mnt/root/arch_chroot.sh
echo "Arch Linux installed successfully!"

# Stop logging and let tee write its last lines before the log is moved
exec 1>&3 2>&4 3>&- 4>&-
wait "${TEE_PID}"
mv archinstall.log /mnt/var/log/archinstall.log
umount -R /mnt

echo "You may reboot now."

#!/bin/bash

# Log all output to file
exec &> >(tee -a archinstall.log)

# Configure keyboard layout
loadkeys "${KEYBOARD}"

# Sync system time via NTP
timedatectl set-ntp true

# Partition disk according to layout file
sfdisk "${DEVICE}" < disk.sfdisk

# Update keyring to prevent GPG errors
pacman --noconfirm -Sy archlinux-keyring

# Configure pacman for parallel downloads
sed -i "s/#ParallelDownloads.*/ParallelDownloads = ${PARALLELDOWNLOADS}/" /etc/pacman.conf

# Create filesystems
mkfs.fat -F 32 "${EFI_PARTITION}"
mkfs.ext4 -F "${ROOT_PARTITION}"

# Mount root partition
mount "${ROOT_PARTITION}" /mnt

# Install base system
pacstrap /mnt base base-devel linux linux-headers linux-firmware dkms

# Generate filesystem table
genfstab -U /mnt >> /mnt/etc/fstab

# Copy and execute chroot script
cp arch_chroot.sh /mnt/root/arch_chroot.sh
arch-chroot /mnt /root/arch_chroot.sh

# Archive installation log
mv archinstall.log /mnt/var/log/archinstall.log

# Cleanup and unmount
rm /mnt/root/arch_chroot.sh
umount -R /mnt

echo "Arch Linux installed successfully! You may reboot now."
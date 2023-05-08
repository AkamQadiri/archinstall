#!/bin/sh
exec &> >(tee -a arch_live.log)

#Set the console keyboard layout
loadkeys $KEYBOARD

#Update the system clock
timedatectl set-ntp true

#Partition the disks
sfdisk $DEVICE < disk.sfdisk

#Installing keyring to avoid gpg error messages
pacman --noconfirm -Sy archlinux-keyring

#Optimize pacman.conf
sed -i "s/#ParallelDownloads.*/ParallelDownloads = $PARALLELDOWNLOADS/" /etc/pacman.conf

#Format the partitions
mkfs.fat -F 32 $EFI_PARTITION
mkfs.ext4 -F $ROOT_PARTITION

#Mount the root partition
mount $ROOT_PARTITION /mnt

#Install essential packages
pacstrap /mnt base base-devel linux linux-headers linux-firmware

#Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot
cp arch_chroot.sh /mnt/root/arch_chroot.sh
arch-chroot /mnt /root/arch_chroot.sh

#Move log files
mkdir /mnt/var/log/archinstall
mv arch_live.log /mnt/var/log/archinstall
mv /mnt/arch_chroot.log /mnt/var/log/archinstall

#Clean up and unmount
rm /mnt/root/arch_chroot.sh
umount -R /mnt

echo "Arch Linux installed successfully! You may reboot now."
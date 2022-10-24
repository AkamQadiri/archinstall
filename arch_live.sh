#!/bin/sh

#Format the partitions
mkfs.fat -F 32 $EFI_PARTITION
mkfs.ext4 -F $ROOT_PARTITION

#Mount the root partition
mount $ROOT_PARTITION /mnt

#Install essential packages
pacstrap /mnt base base-devel linux linux-firmware

#Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot
cp arch_chroot.sh /mnt/root/arch_chroot.sh
arch-chroot /mnt /root/arch_chroot.sh

#Clean up and unmount
rm /mnt/root/arch_chroot.sh
umount -R /mnt

echo "Arch Linux installed successfully! You may reboot now."
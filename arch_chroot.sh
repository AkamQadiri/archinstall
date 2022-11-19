#!/bin/sh

#Time zone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

#Localization
sed -i "/$LANGUAGE/s/^#e/e/g" /etc/locale.gen
locale-gen
echo "LANG=$LANGUAGE" >> /etc/locale.conf
echo "KEYMAP=$KEYBOARD" >> /etc/vconsole.conf

#Network configuration
echo $HOSTNAME >> /etc/hostname
echo "" >> /etc/hosts
echo "127.0.0.1      localhost" >> /etc/hosts
echo "::1            localhost" >> /etc/hosts
echo "127.0.0.1      $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

#Create user
useradd -m $USER_NAME
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

#Essential packages
pacman --noconfirm -S $X_PACKAGES $DRIVER_PACKAGES $AUDIO_PACKAGES $FONT_PACKAGES $ADDITIONAL_PACKAGES
pacman --noconfirm -S grub efibootmgr networkmanager ufw

#Add user to groups
usermod -aG $USER_GROUPS $USER_NAME

#Setup sudo
echo '%wheel ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/default
echo 'ALL ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown' | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/default

#Using this to avoid sudo prompts when setting up the environment, will be removed later
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/temp

#Install grub
mount --mkdir $EFI_PARTITION /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#Systemctl services
systemctl enable NetworkManager ufw
systemctl --global enable $SYSTEMCTL_GLOBAL_SERVICES

#UFW
ufw default deny
ufw enable

#Optimize pacman.conf
sed -i 's/#ParallelDownloads.*/ParallelDownloads = 15/' /etc/pacman.conf

#Optimize makepkg.conf to speed up compilation time
sed -i 's/-march=x86-64 -mtune=generic/-march=native/' /etc/makepkg.conf
sed -i 's/#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

#Check if git is installed
if command -v git &> /dev/null; then
 #Configure git
 su $USER_NAME -c "git config --global user.email $GIT_EMAIL"
 su $USER_NAME -c "git config --global user.name $GIT_NAME"
 su $USER_NAME -c "git config --global credential.helper store"

 #Install yay
 su $USER_NAME -c "cd ~; git clone https://aur.archlinux.org/yay-bin.git; cd yay-bin; makepkg -s"

 cd /home/$USER_NAME/yay-bin
 pacman --noconfirm -U *.pkg.tar.zst

 #Delete yay directory
 rm -r /home/$USER_NAME/yay-bin

 #Install YAY Packages
 su $USER_NAME -c "yay -S $YAY_PACKAGES --answerclean All --answerdiff None --mflags '--noconfirm'"

 #Install and build from repos
 su $USER_NAME -c "cd ~; mkdir source"

 repositories=("dwm" "dwmblocks-async" "st" "dmenu" "slock")
 for repo in ${repositories[@]}; do
  su $USER_NAME -c "cd ~/source; git clone https://github.com/$GIT_NAME/$repo; cd $repo; sudo make clean install; sudo make clean;"
 done

 su $USER_NAME -c "cd ~/source; git clone https://github.com/$GIT_NAME/dotfiles; cd dotfiles; ./install.sh"
fi

#Should be removed now that the environment has been set up
rm /etc/sudoers.d/temp
#!/bin/sh

#Optimize pacman.conf
sed -i "s/#ParallelDownloads.*/ParallelDownloads = $PARALLELDOWNLOADS/" /etc/pacman.conf

#Optimize makepkg.conf to speed up compilation time
sed -i 's/-march=x86-64 -mtune=generic/-march=native/' /etc/makepkg.conf
sed -i 's/#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

#Time zone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

#Localization
sed -i "/$LANGUAGE/s/^#//" /etc/locale.gen
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

#Install packages
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

if [ ! -z "$LIBVIRT_PACKAGES" ]; then
    pacman --noconfirm -S $LIBVIRT_PACKAGES
    sed -i '/#unix_sock_group/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i '/#unix_sock_ro_perms/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i '/#unix_sock_rw_perms/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i 's/#auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/libvirtd.conf
    sed -i 's/#auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/libvirtd.conf
    systemctl enable libvirtd
    virsh net-autostart default
    usermod -aG libvirt $USER_NAME
fi

#Check if git is installed
if [ command -v git &> /dev/null ]; then

    #Configure git
    su $USER_NAME -c "git config --global credential.helper store"

    if [ -z "$GIT_EMAIL" ]; then
        su $USER_NAME -c "git config --global user.email $GIT_EMAIL"
    fi

    if [ -z "$GIT_NAME" ]; then
        su $USER_NAME -c "git config --global user.name $GIT_NAME"
    fi

    if [ ! -z "$YAY_PACKAGES" ]; then
        #Install yay
        su $USER_NAME -c "cd ~; git clone https://aur.archlinux.org/yay-bin.git; cd yay-bin; makepkg -s"

        cd /home/$USER_NAME/yay-bin
        pacman --noconfirm -U *.pkg.tar.zst

        #Delete yay directory
        rm -r /home/$USER_NAME/yay-bin

        #Install YAY Packages
        su $USER_NAME -c "echo y | yay -S $YAY_PACKAGES --removemake --answerclean All --answerdiff None --mflags '--noconfirm'"
    fi

    #Install and build from repos
    su $USER_NAME -c "cd ~; mkdir source"

    repositories=($GITHUB_REPOSITORIES)
    for repo in ${repositories[@]}; do
        su $USER_NAME -c "cd ~/source; git clone https://github.com/$GIT_NAME/$repo; cd $repo; sudo make clean install; sudo make clean;"
    done

    su $USER_NAME -c "cd ~/source; git clone https://github.com/$GIT_NAME/$GITHUB_DOTFILES_REPOSITORY; cd $GITHUB_DOTFILES_REPOSITORY; ./install.sh"
fi

#Should be removed now that the environment has been set up
rm /etc/sudoers.d/temp
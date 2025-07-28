#!/bin/bash

# Configure pacman for parallel downloads
sed -i "s/#ParallelDownloads.*/ParallelDownloads = ${PARALLELDOWNLOADS}/" /etc/pacman.conf

# Optimize compilation flags for native CPU
sed -i 's/-march=x86-64 -mtune=generic/-march=native/' /etc/makepkg.conf
sed -i "s/#MAKEFLAGS=.*/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf
sed -i 's/ debug / !debug /' /etc/makepkg.conf

# Configure timezone
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

# Configure locale
sed -i "/${LANGUAGE}/s/^#//" /etc/locale.gen
locale-gen
echo "LANG=${LANGUAGE}" >> /etc/locale.conf
echo "KEYMAP=${KEYBOARD}" >> /etc/vconsole.conf

# Configure network
{
    echo "${HOSTNAME}"
} > /etc/hostname

{
    echo "127.0.0.1      localhost"
    echo "::1            localhost"
    echo "127.0.0.1      ${HOSTNAME}.localdomain ${HOSTNAME}"
} > /etc/hosts

# Create user account
useradd -m "${USER_NAME}"
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# Install system packages
# shellcheck disable=SC2086  # We need word splitting for package lists
pacman --noconfirm -S ${X_PACKAGES} ${DRIVER_PACKAGES} ${AUDIO_PACKAGES} ${FONT_PACKAGES} ${ADDITIONAL_PACKAGES} grub efibootmgr networkmanager

# Configure user groups
usermod -aG "${USER_GROUPS}" "${USER_NAME}"

# Configure sudo access
echo '%wheel ALL=(ALL:ALL) ALL' | EDITOR='tee -a' visudo -f /etc/sudoers.d/default
echo 'ALL ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown' | EDITOR='tee -a' visudo -f /etc/sudoers.d/default

# Temporary passwordless sudo for setup
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo -f /etc/sudoers.d/temp

# Install GRUB bootloader
mount --mkdir "${EFI_PARTITION}" /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable system services
systemctl enable NetworkManager
# shellcheck disable=SC2086  # We need word splitting for service lists
systemctl --global enable ${SYSTEMCTL_GLOBAL_SERVICES}

# Configure virtualization (if enabled)
if [[ -n "${LIBVIRT_PACKAGES}" ]]; then
    # shellcheck disable=SC2086  # We need word splitting for package lists
    pacman --noconfirm -S ${LIBVIRT_PACKAGES}
    
    # Configure libvirt permissions
    sed -i '/#unix_sock_group/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i '/#unix_sock_ro_perms/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i '/#unix_sock_rw_perms/s/^#//' /etc/libvirt/libvirtd.conf
    sed -i 's/#auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/libvirtd.conf
    sed -i 's/#auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/libvirtd.conf
    
    systemctl enable libvirtd
    usermod -aG libvirt "${USER_NAME}"
fi

# Configure development environment (if git installed)
if command -v git &> /dev/null; then
    # Configure git credentials
    su "${USER_NAME}" -c "git config --global credential.helper /usr/lib/git-core/git-credential-libsecret"
    
    # Enable Git LFS if available
    if command -v git-lfs &> /dev/null; then
        su "${USER_NAME}" -c "git lfs install"
    fi
    
    # Set git identity
    if [[ -n "${GIT_EMAIL}" ]]; then
        su "${USER_NAME}" -c "git config --global user.email '${GIT_EMAIL}'"
    fi
    
    if [[ -n "${GIT_NAME}" ]]; then
        su "${USER_NAME}" -c "git config --global user.name '${GIT_NAME}'"
    fi
    
    # Install AUR helper and packages
    if [[ -n "${YAY_PACKAGES}" ]]; then
        # Build and install yay
        su "${USER_NAME}" -c "cd ~; git clone https://aur.archlinux.org/yay-bin.git; cd yay-bin; makepkg -s"
        
        cd "/home/${USER_NAME}/yay-bin" || exit 1
        pacman --noconfirm -U ./*.pkg.tar.zst
        
        rm -r "/home/${USER_NAME}/yay-bin"
        
        # Install dependencies first
        if [[ -n "${AUR_DEPENDENCIES}" ]]; then
            # shellcheck disable=SC2086  # We need word splitting for package lists
            pacman --noconfirm -S ${AUR_DEPENDENCIES}
        fi
        
        # Install AUR packages
        su "${USER_NAME}" -c "yay -S ${YAY_PACKAGES} --removemake --answerclean All --answerdiff None --noconfirm"
    fi
    
    # Clone and build GitHub repositories
    su "${USER_NAME}" -c "cd ~; mkdir -p source"
    
    if [[ -n "${GITHUB_REPOSITORIES}" ]]; then
        IFS=' ' read -ra repositories <<< "${GITHUB_REPOSITORIES}"
        for repo in "${repositories[@]}"; do
            su "${USER_NAME}" -c "cd ~/source; git clone https://github.com/${GIT_NAME}/${repo}; cd ${repo}; sudo make clean install; sudo make clean;"
        done
    fi
    
    # Install dotfiles
    if [[ -n "${GITHUB_DOTFILES_REPOSITORY}" ]]; then
        su "${USER_NAME}" -c "cd ~/source; git clone https://github.com/${GIT_NAME}/${GITHUB_DOTFILES_REPOSITORY}; cd ${GITHUB_DOTFILES_REPOSITORY}; ./install.sh"
    fi
fi

# Remove temporary sudo permissions
rm /etc/sudoers.d/temp
#!/bin/bash
set -euo pipefail

# Arch Linux chroot environment configuration script
# Configures system settings, users, packages, and bootloader

# === PACMAN CONFIGURATION ===
sed -i "s/#ParallelDownloads.*/ParallelDownloads = ${PARALLELDOWNLOADS}/" /etc/pacman.conf

# === MAKEPKG OPTIMIZATION ===
sed -i 's/-march=x86-64 -mtune=generic/-march=native/' /etc/makepkg.conf
sed -i "s/#MAKEFLAGS=.*/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf
sed -i 's/ debug / !debug /' /etc/makepkg.conf

# === TIMEZONE CONFIGURATION ===
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

# === LOCALE CONFIGURATION ===
sed -i "/${LANGUAGE}/s/^#//" /etc/locale.gen
locale-gen
echo "LANG=${LANGUAGE}" >/etc/locale.conf
echo "KEYMAP=${KEYBOARD}" >/etc/vconsole.conf

# === NETWORK CONFIGURATION ===
echo "${HOSTNAME}" >/etc/hostname

{
    echo "127.0.0.1      localhost"
    echo "::1            localhost"
    echo "127.0.0.1      ${HOSTNAME}.localdomain ${HOSTNAME}"
} >/etc/hosts

# === USER CREATION ===
useradd -m "${USER_NAME}"
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# === PACKAGE INSTALLATION ===
# shellcheck disable=SC2086  # We need word splitting for package lists
pacman --noconfirm -S ${X_PACKAGES} ${DRIVER_PACKAGES} ${AUDIO_PACKAGES} ${FONT_PACKAGES} ${ADDITIONAL_PACKAGES} grub efibootmgr networkmanager

# === USER GROUP CONFIGURATION ===
usermod -aG "${USER_GROUPS}" "${USER_NAME}"

# === SUDO CONFIGURATION ===
{
    echo '%wheel ALL=(ALL:ALL) ALL'
    echo 'ALL ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown'
} >/etc/sudoers.d/default

# Temporary passwordless sudo for setup
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/temp

# === BOOTLOADER INSTALLATION ===
mount --mkdir "${EFI_PARTITION}" /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub

# === SERVICE CONFIGURATION ===
systemctl enable NetworkManager
# shellcheck disable=SC2086  # We need word splitting for service lists
systemctl --global enable ${SYSTEMCTL_GLOBAL_SERVICES}

# === VIRTUALIZATION CONFIGURATION ===
configure_virtualization() {
    # shellcheck disable=SC2086  # We need word splitting for package lists
    pacman --noconfirm -S ${LIBVIRT_PACKAGES}

    # Configure libvirt permissions
    sed -i -e '/#unix_sock_group/s/^#//' \
        -e '/#unix_sock_ro_perms/s/^#//' \
        -e '/#unix_sock_rw_perms/s/^#//' \
        -e 's/#auth_unix_ro.*/auth_unix_ro = "none"/' \
        -e 's/#auth_unix_rw.*/auth_unix_rw = "none"/' \
        /etc/libvirt/libvirtd.conf

    systemctl enable libvirtd
    usermod -aG libvirt "${USER_NAME}"

    # Configure IOMMU for bare metal
    if ! systemd-detect-virt -q; then
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 iommu=pt"/' /etc/default/grub
        sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 vfio_pci vfio vfio_iommu_type1)/' /etc/mkinitcpio.conf
        mkinitcpio -P
    fi
}

[[ -n "${LIBVIRT_PACKAGES:-}" ]] && configure_virtualization

# === GRUB CONFIGURATION ===
grub-mkconfig -o /boot/grub/grub.cfg

# === DEVELOPMENT ENVIRONMENT ===
configure_development() {
    # Create source directory for git repositories
    su "${USER_NAME}" -c "mkdir -p ~/source"

    # Git configuration
    su "${USER_NAME}" -c "git config --global credential.helper /usr/lib/git-core/git-credential-libsecret"

    # Git LFS
    if command -v git-lfs &>/dev/null; then
        su "${USER_NAME}" -c "git lfs install"
    fi

    # Git identity
    [[ -n "${GIT_EMAIL:-}" ]] && su "${USER_NAME}" -c "git config --global user.email '${GIT_EMAIL}'"
    [[ -n "${GIT_NAME:-}" ]] && su "${USER_NAME}" -c "git config --global user.name '${GIT_NAME}'"

    # AUR helper installation
    if [[ -n "${AUR_PACKAGES:-}" ]]; then
        install_aur_helper
        install_aur_packages
    fi

    # GitHub repositories
    if [[ -n "${GITHUB_REPOSITORIES:-}" ]]; then
        clone_and_build_repositories
    fi

    # Dotfiles installation
    if [[ -n "${GITHUB_DOTFILES_REPOSITORY:-}" ]]; then
        install_dotfiles
    fi
}

install_aur_helper() {
    local build_dir="/home/${USER_NAME}/yay-bin"

    su "${USER_NAME}" -c "git clone https://aur.archlinux.org/yay-bin.git '${build_dir}'"
    su "${USER_NAME}" -c "cd '${build_dir}' && makepkg -s"

    pacman --noconfirm -U "${build_dir}"/*.pkg.tar.zst
    rm -rf "${build_dir}"
}

install_aur_packages() {
    # Install dependencies if specified
    if [[ -n "${AUR_DEPENDENCIES:-}" ]]; then
        # shellcheck disable=SC2086  # We need word splitting
        pacman --noconfirm -S ${AUR_DEPENDENCIES}
    fi

    # Install AUR packages
    su "${USER_NAME}" -c "yay -S ${AUR_PACKAGES} --removemake --answerclean All --answerdiff None --noconfirm"
}

clone_and_build_repositories() {
    IFS=' ' read -ra repositories <<<"${GITHUB_REPOSITORIES}"
    for repo in "${repositories[@]}"; do
        su "${USER_NAME}" -c "
            cd ~/source
            git clone 'https://github.com/${GIT_NAME}/${repo}'
            cd '${repo}'
            sudo make clean install
            sudo make clean
        "
    done
}

install_dotfiles() {
    su "${USER_NAME}" -c "
        cd ~/source
        git clone 'https://github.com/${GIT_NAME}/${GITHUB_DOTFILES_REPOSITORY}'
        cd '${GITHUB_DOTFILES_REPOSITORY}'
        ./install.sh
    "
}

command -v git &>/dev/null && configure_development

# === CLEANUP ===
rm -f /etc/sudoers.d/temp

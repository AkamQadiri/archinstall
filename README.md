# Arch Linux Automated Installation

Automated installation for Arch Linux with hardware detection, AUR support, and dotfiles integration.

## Overview

This project provides a set of bash scripts to automate the installation of Arch Linux with a preconfigured desktop environment, automatic hardware detection, and optional virtualization support.

## Features

- Automatic hardware detection (Intel/AMD CPU, AMD/NVIDIA GPU)
- UEFI boot with GRUB
- X11 desktop environment with PipeWire audio
- AUR helper (yay) installation
- GitHub repository integration for custom builds and dotfiles
- Optional virtualization host support (libvirt/QEMU)
- VM guest detection with automatic tools installation

## File Structure

- `install.sh` - Main configuration file and entry point
- `arch_live.sh` - Executes in the live environment
- `arch_chroot.sh` - Executes in the chroot environment
- `disk.sfdisk` - Disk partitioning layout (GPT with EFI and root)

## Installation

1. Boot into Arch Linux installation media

2. Install git:

   ```bash
   pacman -Sy git
   ```

3. Clone this repository:

   ```bash
   git clone https://github.com/AkamQadiri/archinstall.git
   cd archinstall
   ```

4. Edit `install.sh` to configure:

   - System settings (hostname, timezone, locale)
   - User credentials
   - Target disk device
   - Package selections
   - Git repositories

5. Execute the installation:
   ```bash
   source install.sh
   ```

## Configuration

### Required Settings

- `DEVICE` - Target installation disk (verify with `lsblk`)
- `USER_NAME` - Primary user account name
- `USER_PASSWORD` - User password (consider changing post-install)

### Optional Features

- Uncomment `LIBVIRT_PACKAGES` to enable virtualization host support
- Configure `YAY_PACKAGES` for AUR packages
- Set `GITHUB_REPOSITORIES` for custom builds (requires Makefile)
- Set `GITHUB_DOTFILES_REPOSITORY` for dotfiles (requires install.sh)

## Partition Layout

| Partition | Size      | Type | Mount Point |
| --------- | --------- | ---- | ----------- |
| Part 1    | 512 MiB   | EFI  | /boot/efi   |
| Part 2    | Remaining | ext4 | /           |

## Hardware Support

The scripts automatically detect and install drivers for:

- Intel/AMD microcode
- AMD GPU (Vulkan)
- NVIDIA GPU (proprietary drivers)
- VM guest additions (QEMU)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# archinstall

Bash scripts that automate an Arch Linux installation with hardware detection, AUR support, and dotfiles integration.

## Overview

The scripts partition the target disk, install a base system, detect CPU, GPU and laptop hardware, and set up an i3 window manager session with PipeWire audio and Bluetooth. Virtualization host support and installation of your own builds and dotfiles are optional.

## Features

- Hardware detection for Intel/AMD CPUs, Intel/AMD/NVIDIA GPUs and laptops
- UEFI boot with GRUB, plus the `EFI/BOOT/BOOTX64.EFI` fallback for firmware that ignores boot entries
- Swapfile sized to RAM, with hibernation configured
- i3 window manager (X11) with PipeWire audio, Bluetooth and a screen locker
- yay AUR helper
- Custom builds and dotfiles pulled from your GitHub repositories
- Optional virtualization host (libvirt/QEMU), with VFIO and IOMMU configured on bare metal
- QEMU guest agent installed automatically inside a VM

## File structure

- `install.sh` — configuration and entry point
- `arch_live.sh` — runs in the live environment
- `arch_chroot.sh` — runs in the chroot
- `disk.sfdisk` — GPT layout (EFI + root)

## Installation

1. Boot the Arch Linux installation media.

2. Install git:

   ```bash
   pacman -Sy git
   ```

3. Clone the repository:

   ```bash
   git clone https://github.com/AkamQadiri/archinstall.git
   cd archinstall
   ```

4. Edit `install.sh` to set the hostname, timezone, locale, user credentials, target disk, packages, and Git repositories.

5. Run the installation:

   ```bash
   source install.sh
   ```

`install.sh` repartitions and formats `DEVICE`, erasing everything on it. Confirm the device with `lsblk` before running.

## Configuration

Required:

- `DEVICE` — target disk (check with `lsblk`)
- `USER_NAME` — primary user account
- `USER_PASSWORD` — user password (change it after install)

Optional:

- Uncomment `LIBVIRT_PACKAGES` for a virtualization host. On bare metal this also configures IOMMU and the VFIO modules for PCI passthrough.
- `AUR_PACKAGES` — packages to install from the AUR
- `GITHUB_REPOSITORIES` — repositories to clone and build, as `owner/repo` (each needs a Makefile)
- `GITHUB_DOTFILES_REPOSITORY` — dotfiles repository, as `owner/repo` (must contain `install.sh`); can be anyone's

Repositories are cloned from `https://github.com/<owner>/<repo>`, independent of `GIT_NAME`, which only sets the commit author name.

## Partition layout

| Partition | Size      | Type | Mount point |
| --------- | --------- | ---- | ----------- |
| 1         | 512 MiB   | EFI  | /boot/efi   |
| 2         | Remaining | ext4 | /           |

Swap is a `/swapfile` on the root partition, sized to RAM so hibernation fits. The kernel resumes from it via `resume=` and `resume_offset=` in GRUB.

## Hardware support

Detected and installed automatically:

- Intel/AMD microcode
- Intel GPU — VA-API and Vulkan
- AMD GPU — Vulkan
- NVIDIA GPU — open kernel modules (`nvidia-open`)
- Laptop (battery present) — TLP, UPower (critical battery action), SOF audio firmware, `brightnessctl`, `autorandr` display profiles, and `thermald` on Intel CPUs
- QEMU guest agent when running in a VM

## License

MIT — see [LICENSE](LICENSE).

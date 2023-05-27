# Arch Linux Automated Installation

This repository provides a streamlined approach to installing and configuring Arch Linux. It includes an automated installation script and customizable configurations, making it a great template for creating your own automated installation process.

## Features

- **Automated Installation**: The `install.sh` script automatically handles system configuration, partitioning, package selection, user setup, and more, streamlining the installation process.

- **Customization**: Tailor the installation to your preferences by modifying the script and associated files to meet your specific requirements.

- **Virtualization Support**: Optional installation and configuration of libvirt allows you to explore virtualization capabilities on your Arch Linux system.

- **Installation Log**: The installation process logs to the primary installation disk, allowing you to check if everything went smoothly.

## Customization and Additional Steps

- **Customizing the Installation**: Modify the `install.sh` script and associated files to suit your preferences and specific system requirements.

- **GitHub Repository Integration**: Specify GitHub repositories in the `$GITHUB_REPOSITORIES` variable within the `install.sh` script. These repositories will be cloned into the `~/source` directory and built using `make` during the installation process. Ensure that the repositories exist and are public under the GitHub user specified in the `$GIT_NAME` variable.

- **Dotfiles Integration**: Specify the dotfiles repository in the `$GITHUB_DOTFILES_REPOSITORY` variable within the `install.sh` script. The automated installation script will clone the repository and execute the `install.sh` file included in it, setting up your personalized configuration during the Arch Linux installation. Ensure that the repository exists and is public under the GitHub user specified in the `$GIT_NAME` variable.

## Getting Started

1. Boot your computer into the Arch Linux installation ISO.

2. Once booted into the Arch Linux installation environment, install Git by running the following command:
   ```shell
   pacman -Sy git
   ```

3. Clone this repository to your local machine by running the following command (Replace `[URL]` with the actual repository URL):
   ```shell
   git clone [URL]
   ```

4. Navigate to the cloned repository directory.

5. Customize the `install.sh` script and associated files to fit your requirements.

6. Execute the `install.sh` script by running the following command:
   ```shell
   source install.sh
   ```

(Optional) After installation, you can check the archinstall log located at `/var/log/archinstall.log` on the `$DEVICE` disk to ensure everything went smoothly.

## Troubleshooting

If you encounter any issues during the installation process, refer to the Arch Linux documentation for troubleshooting.

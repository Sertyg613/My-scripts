#!/bin/bash
# =========================================================
#  Minimal Arch Linux Auto Installer
#  Layout: EFI + swap (6G) + root (100G) + home (rest)
#  System: UEFI, ext4, systemd-boot, ly login manager
# =========================================================


set -e

echo "=== Arch Linux Minimal Installer ==="
read -p "Enter target disk (example: /dev/sdb): " DISK
read -p "Enter hostname: " HOSTNAME
read -p "Enter username: " USERNAME
read -p "Enter region for timezone (example: Europe/Warsaw): " TZONE

# --- Partitioning -----------------------------------------------------------
echo ">> Partitioning $DISK ..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart EFI fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart swap linux-swap 513MiB 6657MiB
parted -s "$DISK" mkpart root ext4 6657MiB 106657MiB
parted -s "$DISK" mkpart home ext4 106657MiB 100%

EFI="${DISK}1"
SWAP="${DISK}2"
ROOT="${DISK}3"
HOME="${DISK}4"

# --- Formatting -------------------------------------------------------------
echo ">> Formatting partitions ..."
mkfs.fat -F32 "$EFI"
mkswap "$SWAP"
mkfs.ext4 -F "$ROOT"
mkfs.ext4 -F "$HOME"

# --- Mounting ---------------------------------------------------------------
echo ">> Mounting partitions ..."
mount "$ROOT" /mnt
mkdir /mnt/{boot,home}
mount "$EFI" /mnt/boot
mount "$HOME" /mnt/home
swapon "$SWAP"

# --- Base system installation ----------------------------------------------
echo ">> Installing base system ..."
pacstrap /mnt base linux linux-firmware vim networkmanager iw pipewire bluez bluez-utils git

# --- Fstab -----------------------------------------------------------------
genfstab -U /mnt >> /mnt/etc/fstab

# --- Chroot into system ----------------------------------------------------
arch-chroot /mnt /bin/bash <<EOF
set -e
echo ">> Configuring system ..."

# Timezone and clock
ln -sf /usr/share/zoneinfo/$TZONE /etc/localtime
hwclock --systohc

# Locale setup
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Root password
echo "Set root password:"
passwd

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Set password for $USERNAME:"
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable network and bluetooth
systemctl enable NetworkManager
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
# Install and enable ly
pacman -S --noconfirm ly
systemctl enable ly.service

# Install systemd-boot
bootctl install
cat > /boot/loader/entries/arch.conf <<CFG
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=$ROOT rw
CFG

EOF

# --- Finishing --------------------------------------------------------------
echo ">> Installation complete!"
echo "Unmounting and rebooting ..."
umount -R /mnt
swapoff "$SWAP"
reboot




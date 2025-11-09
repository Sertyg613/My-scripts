#! /bin/bash
echo "Instaling Yay!"
sudo pacman -S git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
echo "Done!"

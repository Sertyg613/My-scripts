#! /bin/bash
user=`whoami`
echo "Привет, $user!"
read -p "Вы хотите начать установку? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Вы согласились на установку!;)"
else
    echo "Вы отказались."
    exit
fi
sleep 1
echo "Что-бы продолжить введите пожалуйста пароль sudo."
sleep 0.5
su
sudo pacman -S git noto-fonts-cjk noto-fonts
########################
####INSTALLING YAY######
#######################################################################
echo "Установка yay!"
sleep 1
echo "."
sleep 1
echo ".."
sleep 1
echo "..."
sleep 1
cd /run/media/archilini/my_files/scripts/
chmod +x yay_install.sh
./yay_install.sh
echo "Yay успешно установлен!"
sleep 1
yay -S ttf-ms-fonts
########################
####INSTALING FLATPAK###
######################################################################
echo "Установка flatpak!"
sleep 1
echo "."
sleep 1
echo ".."
sleep 1
echo "..."
sleep 1

sudo pacman -S flatpak

echo "Flatpak успешно установлен!"
sleep 1

######################################################################
#######################Download packges###############################
######################################################################

############################
#####PACKS TO INSTALL#######
####################################################################
flat=("com.heroicgameslauncher.hgl com.valvesoftware.Steam com.visualstudio.code
       org.prismlauncher.PrismLauncher org.kde.KStyle.Adwaita")

packs=("hyprland firefox gnome-text-editor gnome-disk-utility nautilus 
	alacritty htop telegram-desktop adwaita-icon-theme 
	adwaita-fonts waybar discord")
####################################################################

sleep 1
echo "На твой пк установится; $packs"
sleep 3
sudo pacman -S $packs
sleep 1
echo "На твой пк установится; $flat"
sleep 3
flatpak install flathub $flat
sleep 1

#####################################################################
####################Configs waypaper, waybar move PC#################
#####################################################################

read -p "Вы хотите готовые конфиги и систему? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Вы согласились)"
    yay -S waypaper
   # cd /run/media/archilini/my_files/scripts
   # chmod +x configs_waybar+hyprpaper.sh
   # ./configs_waybar+hyprpaper.sh
else
    echo "Вы отказались"
fi



##############################################################################################################
#####################################INSTALING COMPLITE!!!####################################################
##############################################################################################################

echo "Установка завершина!"
sudo pacman -Suy

read -p "Вы хотите перезапустить ПК? (y/n): " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Вы согласились)"
    reboot
else
    echo "Вы отказались"
fi

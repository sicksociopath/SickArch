#!/usr/bin/env bash

chipg=$(sed -n '7{p;q}' temp.txt)
username=$(sed -n '8{p;q}' temp.txt)
usernamepasswd=$(sed -n '9{p;q}' temp.txt)

#Audio Install
pacman -S --noconfirm alsa-card-profiles alsa-firmware alsa-plugins alsa-tools alsa-utils
pacman -S --noconfirm pulseaudio pulseaudio-alsa 

read -p "Press anykey to continue" stop

#Video Card
if [ $chipg == 1 ]; then
	pacman -S --noconfirm nvidia
	nvidia-xconfig
elif [ $chipg == 2 ]; then
	pacman -S --noconfirm libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau xf86-video-amdgpu
	pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon 
	pacman -S --noconfirm vulkan-tools radeontop libva-utils vdpauinfo
	pacman -S --noconfirm mesa lib32-mesa
elif [ $chipg == 3 ]; then
	pacman -S --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel 
	pacman -S --noconfirm libva-intel-driver lib32-libva-intel-driver libvdpau-va-gl 
	pacman -S --noconfirm vulkan-tools intel-gpu-tools libva-utils vdpauinfo
	pacman -S --noconfirm mesa lib32-mesa
elif [ $chipg == 4 ]; then
	pacman -S --noconfirm spice-vdagent xf86-video-qxl
fi

read -p "Press anykey to continue" stop

#Xorg
pacman -S --noconfirm xorg-server xorg-xhost

read -p "Press anykey to continue" stop

#Config Mouse and Keyboard
cp 00-keyboard.conf /etc/X11/xorg.conf.d
cp 10-libinput.conf /etc/X11/xorg.conf.d

read -p "Press anykey to continue" stop

#Install ZSH
pacman -S --noconfirm zsh

read -p "Press anykey to continue" stop

#User
useradd -m -G audio,video,storage,wheel,adm,ftp,games,http,log,rfkill,sys,systemd-journal,uucp -s /bin/zsh $username 
chpasswd <<<$usernamepasswd

read -p "Press anykey to continue" stop

#Install Terminal
pacman -S --noconfirm alacritty

read -p "Press anykey to continue" stop

#Install Shell Tools
pacman -S --noconfirm git neofetch htop ntfs-3g zip unzip android-tools aria2

read -p "Press anykey to continue" stop

#Fonts
pacman -S --noconfirm ttf-fira-code
pacman -S --noconfirm ttf-dejavu

read -p "Press anykey to continue" stop

#Ubuntu
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip 
mkdir /usr/share/fonts/ubuntu
unzip Ubuntu.zip -d /usr/share/fonts/ubuntu 

read -p "Press anykey to continue" stop

#UbuntuMono
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip
mkdir /usr/share/fonts/UbuntuMono
unzip UbuntuMono.zip -d /usr/share/fonts/UbuntuMono

read -p "Press anykey to continue" stop

#Hack
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip 
mkdir /usr/share/fonts/Hack
unzip Hack.zip -d /usr/share/fonts/Hack

read -p "Press anykey to continue" stop

#Looks
pacman -S --noconfirm qtile rofi lightdm lightdm-webkit2-greeter feh
pacman -S --noconfirm qt5ct lxappearance 
pacman -S --noconfirm breeze-gtk

read -p "Press anykey to continue" stop

#Web Browser
pacman -S --noconfirm firefox

read -p "Press anykey to continue" stop

#Tools
pacman -S --noconfirm mupdf
pacman -S --noconfirm keepassxc mpv signal-desktop thunderbird nm-connection-editor network-manager-applet pavucontrol

read -p "Press anykey to continue" stop

#Move Wallpaper
mkdir /home/$username/Pictures
chown $username:$username /home/$username/Pictures
mkdir /home/$username/Pictures/Wallpapers
chown $username:$username /home/$username/Pictures/Wallpapers
cp Wallpaper_2.jpg /home/$username/Pictures/Wallpapers
chown $username:$username /home/$username/Pictures/Wallpapers/Wallpaper_2.jpg

read -p "Press anykey to continue" stop

#Move Config
mkdir /home/$username/.config
mkdir /home/$username/.config/alacritty
chown $username:$username /home/$username/.config/
chown $username:$username /home/$username/.config/alacritty

read -p "Press anykey to continue" stop

cp alacritty.yml /home/$username/.config/alacritty

read -p "Press anykey to continue" stop

chown $username:$username /home/$username/.config/alacritty/alacritty.yml

read -p "Press anykey to continue" stop

mkdir /home/$username/.config/qtile

read -p "Press anykey to continue" stop

chown $username:$username /home/$username/.config/qtile

read -p "Press anykey to continue" stop

cp config.py /home/$username/.config/qtile/

read -p "Press anykey to continue" stop

chown $username:$username /home/$username/.config/qtile/config.py
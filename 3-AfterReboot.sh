#!/usr/bin/env bash

chipg=$(sed -n '7{p;q}' temp.txt)
username=$(sed -n '8{p;q}' temp.txt)
usernamepasswd=$(sed -n '9{p;q}' temp.txt)
line82libvirtd=$(sed -n '13{p;q}' temp.txt)
line93libvirtd=$(sed -n '14{p;q}' temp.txt)
line107libvirtd=$(sed -n '15{p;q}' temp.txt)
line520qemu=$(sed -n '11{p;q}' temp.txt)
line525qemu=$(sed -n '12{p;q}' temp.txt)

#Audio Install
pacman -S --noconfirm alsa-card-profiles alsa-firmware alsa-plugins alsa-tools alsa-utils
pacman -S --noconfirm pulseaudio pulseaudio-alsa 

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

#Xorg
pacman -S --noconfirm xorg-server xorg-xhost

#Config Mouse and Keyboard
cp 00-keyboard.conf /etc/X11/xorg.conf.d
cp 10-libinput.conf /etc/X11/xorg.conf.d

#Install ZSH
pacman -S --noconfirm zsh

#User
useradd -m -G audio,video,storage,wheel,adm,ftp,games,http,log,rfkill,sys,systemd-journal,uucp -s /bin/zsh $username 
chpasswd <<<$usernamepasswd

#Install Terminal
pacman -S --noconfirm alacritty

#Install Shell Tools
pacman -S --noconfirm git neofetch htop ntfs-3g zip unzip android-tools aria2 rust

#Fonts
pacman -S --noconfirm ttf-fira-code
pacman -S --noconfirm ttf-dejavu

#Ubuntu
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip 
mkdir /usr/share/fonts/ubuntu
unzip Ubuntu.zip -d /usr/share/fonts/ubuntu 

#UbuntuMono
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip
mkdir /usr/share/fonts/UbuntuMono
unzip UbuntuMono.zip -d /usr/share/fonts/UbuntuMono

#Hack
aria2c https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip 
mkdir /usr/share/fonts/Hack
unzip Hack.zip -d /usr/share/fonts/Hack

#Looks
pacman -S --noconfirm qtile rofi lightdm lightdm-webkit2-greeter feh
pacman -S --noconfirm qt5ct lxappearance 
pacman -S --noconfirm breeze-gtk

#Web Browser
pacman -S --noconfirm firefox

#Tools
pacman -S --noconfirm mupdf
pacman -S --noconfirm keepassxc mpv signal-desktop thunderbird nm-connection-editor network-manager-applet pavucontrol

#ani-cli
git clone https://github.com/pystardust/ani-cli
chmod +x ani-cli/ani-cli
cp ani-cli/ani-cli /usr/local/bin/

#Move Wallpaper
mkdir /home/$username/Pictures
chown $username:$username /home/$username/Pictures
mkdir /home/$username/Pictures/Wallpapers
chown $username:$username /home/$username/Pictures/Wallpapers
cp Wallpaper_2.jpg /home/$username/Pictures/Wallpapers
chown $username:$username /home/$username/Pictures/Wallpapers/Wallpaper_2.jpg

#Move Config
mkdir /home/$username/.config
mkdir /home/$username/.config/alacritty
chown $username:$username /home/$username/.config/
chown $username:$username /home/$username/.config/alacritty

cp alacritty.yml /home/$username/.config/alacritty

chown $username:$username /home/$username/.config/alacritty/alacritty.yml

mkdir /home/$username/.config/qtile

chown $username:$username /home/$username/.config/qtile

sed -i "157 i os.system(\"feh --bg-fill /home/$username/Pictures/Wallpapers/Wallpaper_2.jpg\")" config.py
cp config.py /home/$username/.config/qtile/

chown $username:$username /home/$username/.config/qtile/config.py

#Install Virt-Manager
pacman -S --noconfirm dmidecode dnsmasq openbsd-netcat libvirt qemu-full
yes | pacman -S --noconfirm iptables-nft
pacman -S --noconfirm virt-manager virt-viewer

#Add user to libvirt group
usermod -aG libvirt $username

#Edit Configs for Virt-Manager
sed -i "82 i $line82libvirtd" /etc/libvirt/libvirtd.conf
sed -i "93 i $line93libvirtd" /etc/libvirt/libvirtd.conf
sed -i "107 i $line107libvirtd" /etc/libvirt/libvirtd.conf
sed -i "520 i $line520qemu" /etc/libvirt/qemu.conf
sed -i "525 i $line525qemu" /etc/libvirt/qemu.conf

#Start libvirt service
systemctl enable libvirtd --now

#Edit LightDM
sed -i "103 i greeter-session=lightdm-webkit2-greeter" /etc/lightdm/lightdm.conf

#Start LightDM service
systemctl enable lightdm

#Edit /etc/makepkg.conf
var=$(nproc)
cp /etc/makepkg.conf /etc/makepkg.conf.backup
sed -i "50 i MAKEFLAGS=\"-j$var\"" /etc/makepkg.conf
sed '139d' /etc/makepkg.conf
sed '140d' /etc/makepkg.conf
sed -i "139 i COMPRESSXZ=(xz -c -z --threads=0 -)" /etc/makepkg.conf
sed -i "140 i COMPRESSZST=(zstd -c -z -q --threads=0 -)" /etc/makepkg.conf

#Config MPV video decoding using GPU
echo "hwdec=auto" > /etc/mpv/mpv.conf

#MPV Youtube Script
cp youtube.sh /usr/local/bin
cp youtubeaudio.sh /usr/local/bin

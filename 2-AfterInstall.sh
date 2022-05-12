#!/usr/bin/env bash

#After arch-chroot

#TimeZone Config
echo "
-----------------------------------------------------------------------
                 Configuring TimeZone and Location
-----------------------------------------------------------------------
"
ls /usr/share/zoneinfo
read -p "Select Region: " region
ls /usr/share/zoneinfo/$region
read -p "Select SubRegion: " subregion
ln -sf /usr/share/zoneinfo/$region/$subregion /etc/localtime
hwclock --systohc

#Troubleshooting
read -p "Press anykey to continue" stop

#Localization
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=la-latin1" > /etc/vconsole.conf

#Get Pacman Config
echo "
-----------------------------------------------------------------------
			 Configuring Pacman 
-----------------------------------------------------------------------
"
#Enable Colors
sed -i '/Color/s/^#//' /etc/pacman.conf
#Enable Parallel Donwloads
sed -i '/ParallelDownloads/s/^#//' /etc/pacman.conf
#Enable 32-bits 
sed -i '93s/^#//' /etc/pacman.conf
sed -i '94s/^#//' /etc/pacman.conf
#Sync Pacman
pacman -Syy
#Keyrings
pacman -S --noconfirm archlinux-keyring
#Sync Pacman
pacman -Syy
#Install rsync and reflector
pacman -S --noconfirm rsync reflector
#BackUp Mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
#Config Mirrors
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist 
#Sync Pacman
pacman -Syy

#Troubleshooting
read -p "Press anykey to continue" stop

#Network Configuration
hostn=$(sed -n '4{p;q}' temp.txt)
echo $hostn > /etc/hostname

#Troubleshooting
read -p "Press anykey to continue" stop

#Root Password
rootpasswd=$(sed -n '5{p;q}' temp.txt)
chpasswd <<<$rootpasswd

#Troubleshooting
read -p "Press anykey to continue" stop

#MicroCode
chip=$(sed -n '6{p;q}' temp.txt)
if [ $chip == 1 ]; then
	pacman -S --noconfirm intel-ucode
else
	pacman -S --noconfirm amd-ucode
fi

#Troubleshooting
read -p "Press anykey to continue" stop

#Bootloader Install and Config
pacman -S --noconfirm grub
pacman -S --noconfirm os-prober

disk=$(sed -n '1{p;q}' temp.txt)
efiyes=$(sed -n '3{p;q}' temp.txt)

if [ $efiyes == 1 ]; then
	pacman -S --noconfirm efibootmgr dosfstools mtools dosfstools
	grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
else
	grub-install --target=i386-pc $disk
fi

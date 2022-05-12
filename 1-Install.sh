#!/usr/bin/env bash

#Get Disk Info
disk=$(sed -n '1{p;q}' temp.txt)
#Get SWAP Info
swapyes=$(sed -n '2{p;q}' temp.txt)
rammem=$(sed -n '10{p;q}' temp.txt)
#Get EFI Info
efiyes=$(sed -n '3{p;q}' temp.txt)

#Timedatectl
timedatectl set-ntp true

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

#Install SGDISK
echo "
-----------------------------------------------------------------------
                         Get SGDISK                                                             
-----------------------------------------------------------------------
"
pacman -S --noconfirm gptfdisk

echo "
-----------------------------------------------------------------------
		     Disk Partitioning
-----------------------------------------------------------------------
"
#Get Disk Ready
if [ $efiyes == 1 ];then
	#UEFI Partitioning
	sgdisk -Z $disk
	sgdisk -a 2048 -o $disk
else 
	#BIOS wont boot with GPT
	fdisk $disk <<EEOF
	o
	w
EEOF
fi
#Troubleshooting
read -p "Press anykey to continue" stop

#Create SWAP
#Need SWAP?
if [ $swapyes == 1 ];then
	if [ $efiyes == 1 ]; then
		#for UEFI
		#Get SWAP size
		swapsize=$(awk '{print "+" $1 "G"}'<<< $rammem)
		swapdir=$(awk '{print $1 "1"}' <<< $disk)
		#Create Partition
		sgdisk -n 1::$swapsize -t 1:8200 $disk  
	else
		#for BIOS
		#Get SWAP size
		swapsize=$(awk '{print "+" $1 "G"}'<<< $rammem)
		swapdir=$(awk '{print $1 "1"}' <<< $disk)
		#Create Partition
		fdisk $disk <<EEOF
		n
		p
		1
		
		$swapsize
		t
		82
		w
EEOF
	fi
fi

#Troubleshooting
read -p "Press anykey to continue" stop

#Bootloader Partition
#Need EFI?
if [ $efiyes == 1 ];then
	#Create Partition
	sgdisk -n 2::+1024M -t 2:ef00 $disk  
	#Get EFI Partition Directory
	EFIdir=$(awk '{print $1 "2"}' <<< $disk)
else
	#Create a Boot Partition
	#Get boot Partition Directory
	bootdir=$(awk '{print $1 "2"}' <<< $disk)
	fdisk $disk <<EEOF
	n
	p
	2
	
	+1024M
	a
	2
	w
EEOF
fi

#Troubleshooting
read -p "Press anykey to continue" stop

#Root Partition
if [ $efiyes == 1 ];then
	sgdisk -n 3::-0 -t 3:8300 $disk  
	rootdir=$(awk '{print $1 "3"}' <<< $disk)
else
	#for BIOS
	rootdir=$(awk '{print $1 "3"}' <<< $disk)
	fdisk $disk <<EEOF
	n
	p
	3
	

	w
EEOF
fi

#Troubleshooting
read -p "Press anykey to continue" stop

#Read new partiton table 
partprobe

#Troubleshooting
read -p "Press anykey to continue" stop

#File System
#SWAP
if [ $swapyes == 1 ];then
	mkswap $swapdir
fi

#Bootloader
if [ $efiyes == 1 ];then
	mkfs.fat -F32 $EFIdir
else	
	mkfs.ext2 $bootdir
fi

#Root
mkfs.ext4 $rootdir

#Troubleshooting
read -p "Press anykey to continue" stop


#Mount Disk Partitions
#SWAP
if [ $swapyes == 1 ];then
	swapon $swapdir
fi

#Root
mount $rootdir /mnt

#Bootloader
if [ $efiyes == 0 ];then
	mkdir /mnt/boot
	mount $bootdir /mnt/boot
else	
	mkdir /mnt/boot
	mkdir /mnt/boot/EFI
	mount $EFIdir /mnt/boot/EFI
fi

#Troubleshooting
read -p "Press anykey to continue" stop

#Base Install
pacstrap /mnt base base-devel linux linux-firmware vim networkmanager  

#Generate Fstab Tables
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

#Copy Script to Arch Install
cp -r /root/SickArch /mnt 

#Get To New Arch Install
arch-chroot /mnt

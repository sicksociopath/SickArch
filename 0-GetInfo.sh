#!/usr/bin/env bash

#Start Info Collect
echo "
-----------------------------------------------------------------------
		       Getting Important Information 
-----------------------------------------------------------------------
"

#Select Disk
#Get All Drives
options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))
echo "
-----------------------------------------------------------------------
			Select HDD for Installation 
-----------------------------------------------------------------------
"
#Amount of Options
limit=${#options[@]}
#Print Options
for (( i=0 ; i<$limit ; i++ ))
do
	echo "-------------------"
	echo "Option" $i
	echo "-------------------"
	echo ${options[i]}
done
#Take Option
read -p "Please Insert Number Only: " select
#Save Selection
disk=${options[$select]%|*}
echo "Drive selected is:"
echo $disk

#SWAP Partition
#Get RAM size
memory=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
#Check RAM size | Less than 16GB needs SWAP
if [ $memory -lt 16000000 ]; then
	swapyes=1
	echo "SWAP will be created"
else
	swapyes=0
	echo "SWAP will not be created"
fi
rammem=$(expr $memory \* 2 / 1000000)

#Check Boot and UEFI
if [ ! -d "/sys/firmware/efi" ]; then
	efiyes=0
	echo "BIOS system detected"
else
	efiyes=1
	echo "UEFI system detected"
fi

#MicroCode
if lscpu | grep -E 'GenuineIntel'; then
	chip=1
	echo "Intel Processor Detected"
elif lscpu | grep -E 'AuthenticAMD'; then 
	chip=2
	echo "AMD Processor Detected"
fi

#Video Card
if lspci | grep 'VGA' | grep -E "NVIDIA|GeForce"; then
	chipg=1
	echo "NVIDIA GPU Detected"
elif lspci | grep 'VGA' | grep -E "AMD"; then
	chipg=2
	echo "Radeon|AMD GPU Detected"
elif lspci | grep 'VGA' | grep -E "Intel"; then
	chipg=3
	echo "Integrated Graphics Controller Detected"
elif lspci | grep 'VGA' | grep -E "Red Hat, Inc. Virtio GPU"; then
	chipg=4
	echo "Virtio GPU Detected"
fi

#Network Configuration
read -p "Name Your Box: " hostn

#Root Password
read -p "Insert Password For Root: " rootpasswd

#User Info
read -p "Insert User Name: " username
read -p $"Insert Password For ${username}: " usernamepasswd

#Write to File
#Selected disk
echo $disk > temp.txt
#SWAP selection
echo $swapyes >> temp.txt
#EFI detection
echo $efiyes >> temp.txt
#Host name
echo $hostn >> temp.txt
#Root Passwd
echo "root:${rootpasswd}" >> temp.txt
#Processor type
echo $chip >> temp.txt
#GPU type
echo $chipg >> temp.txt
#Username
echo $username >> temp.txt
#New user passwd
echo "${username}:${usernamepasswd}" >> temp.txt
#RAM amount
echo $rammem >> temp.txt
#Virt-Manager config
echo "user = "$username"" >> temp.txt
echo "group = "$username"" >> temp.txt
echo "unix_sock_group = "libvirt"" >> temp.txt
echo "unix_sock_ro_perms = "0777"" >> temp.txt
echo "unix_sock_rw_perms = "0770"" >> temp.txt

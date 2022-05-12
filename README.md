# SickArch Installer Script 

Automatization of Archlinux Installation using Bash Scripts.

---
## You'll need
Bootable USB device with Archlive ISO in it.

This device will be called ArchUSB from now on.

---
## How to use?
Plug the ArchUSB to the PC.

Research how to access the Boot Menu of the PC.

Restart PC and get to Boot Menu.

Select ArchUSB and boot from it.

### After booting into Archlive Shell
Configure keyboard. Get a list of available heyboards with:

```
ls /usr/share/kbd/keymaps/**/*.map.gz
```

Set keyboard with:

```
loadkeys [option]
```

Get internet connection. Ethernet usually works out of the box. For wifi:

Configure wpa_supplicant by writting the next .conf file:

```
echo "ctrl_interface=/run/wpa_supplicant > /etc/wpa_supplicant.conf"
echo "update_config=1" >> /etc/wpa_supplicant.conf
```

Start wpa_supplicant by:

```
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
wpa_cli
```

Add network
```
add_network 0
```

Scan wifi networks
```
scan
scan_results
```

After selecting a wifi network
```
set_network 0 ssid "WIFI_NAME"
set_network 0 psk "WIFI_PASSWORD"
enable_network 0
save_config
quit
```

If the wifi has not password, replace second line of the last text with:
```
set_netowork 0 key_mgmt NONE
```

Get files in this repo 
```
pacman -Syy && pacman -S --noconfirm git && git clone https://github.com/sicksociopath/SickArch
```

Run scripts in this order
```
./0-GetInfo.sh
./1-Install.sh
cp SickArch
./2-AfterReboot.sh
umount -R /mnt
reboot now
```
Log into root user with assinged password, then:
```
./3-AfterReboot.sh
```

#!/usr/bin/env bash

#Install PARU
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd /SickArch
rm -rf paru

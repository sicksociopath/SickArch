#!/usr/bin/env bash

#Inputs
link=$1
speed=$2

mpv --ytdl-format="bestaudio" --speed=$speed $link

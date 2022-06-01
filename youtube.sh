#!/usr/bin/env bash

#Inputs
link=$1
speed=$2

mpv --ytdl-format="bestvideo[vcodec^=avc1]+bestaudio" --no-terminal --x11-name="MPV" --speed=$speed $link

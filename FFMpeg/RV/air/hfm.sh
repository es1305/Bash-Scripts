#!/bin/bash
CHANNEL=HeartFM
HW=hw:CARD=Intel,DEV=0
HOME=/srv/air/$CHANNEL/$(date +%Y)/$(date +%m)
FOLDER=$(date +%d)
NAME="$CHANNEL"_%Y%m%d_%H-%M.mp3

if [ ! -d "$HOME/$FOLDER" ]; then
  mkdir -p $HOME/$FOLDER
fi

ffmpeg -v fatal -f alsa -i $HW -c:a libmp3lame -q:a 8 \
  -f segment -strftime 1 -segment_time 3600 \
  -segment_atclocktime 1 -reset_timestamps 1 \
  $HOME/$FOLDER/$NAME

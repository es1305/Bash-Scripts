#!/bin/bash
CHANNEL=HeartFM-Kamen
HW=http://109.248.235.192:8000/live
HOME=/srv/air/$CHANNEL/$(date +%Y)/$(date +%m)
FOLDER=$(date +%d)
NAME="$CHANNEL"_%Y%m%d_%H-%M.mp3

if [ ! -d "$HOME/$FOLDER" ]; then
  mkdir -p $HOME/$FOLDER
fi

ffmpeg -hide_banner -i $HW -c copy \
  -f segment -strftime 1 -segment_time 3600 \
  -segment_atclocktime 1 -reset_timestamps 1 \
  $HOME/$FOLDER/$NAME

#!/bin/bash
HOME=/srv/air
TIME=-mtime\ +184

echo -e "\nWaiting for 58 second to kill all FFMpeg..."

for i in {01..58}; do
  sleep 1
  printf "\r => $i seconds have passed"
done

killall ffmpeg

echo -e "\n\nWaiting for 10 secound to cleanup folders..."

for i in {01..10}; do
  sleep 1
  printf "\r => $i seconds have passed"
done

find $HOME -type f $TIME -exec rm -f {} \; > /dev/null 2>&1
find $HOME -depth -mindepth 1 -type d -empty -exec rmdir {} \; > /dev/null 2>&1

echo -e "\n\nAll done!"

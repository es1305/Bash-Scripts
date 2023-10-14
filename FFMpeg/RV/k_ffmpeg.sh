#!/bin/bash
HOME=/srv/air
TIME=-mtime\ +365

sleep 57
killall ffmpeg
sleep 10
# 1 Month for Kamen'
find $HOME/HeartFM-Kamen -type f -mtime +31 -exec rm -f {} \;
# 1 Year for all others
find $HOME -type f $TIME -exec rm -f {} \;
find $HOME -depth -mindepth 1 -type d -empty -exec rmdir {} \;

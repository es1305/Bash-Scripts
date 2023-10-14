#!/bin/bash

######################################
# Check ffmpeg
######################################

if [[ $(pgrep russia1.sh) -gt 0 ]]; then
  echo "russia1.sh already running!"
  echo "Process ID $(pgrep russia1.sh)"
else
    /root/script/russia1.sh
fi

#!/bin/bash
PATH="$HOME/bin:$PATH"
BIN=/root/bin
HOME=/srv/Russia1/$(date +%Y)/$(date +%m)
FOLDER=$(date +%d)

if [ ! -d "$HOME/$FOLDER" ]; then
    mkdir -p $HOME/$FOLDER
fi

$BIN/ffmpeg -v fatal -f decklink -i 'DeckLink Mini Recorder' \
    -r 25000/1000 -format_code Hi50 -maxrate 5000k -bufsize 10000k \
    -c:v h264 -s hd720 -preset medium -profile:v high -pix_fmt yuv420p \
    -map_metadata -1 -bf 2 -g 25 -coder 1 -crf 21 -vf yadif \
    -c:a libfdk_aac -ac 2 -ar 48000 -profile:a aac_low -b:a 128k \
    -f segment -strftime 1 -segment_time 3600 -segment_atclocktime 1 \
    -reset_timestamps 1 -segment_format_options movflags=+faststart \
    $HOME/$FOLDER/Russia1_%Y%m%d_%H-%M.mp4

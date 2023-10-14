#!/bin/bash
BIN=/home/eugene/bin
HOME=/srv/air/Russia24/`date +%Y`/`date +%m`
FOLDER=`date +%d`

if [ ! -d "$HOME/$FOLDER" ]
then
    mkdir -p $HOME/$FOLDER
fi

$BIN/ffmpeg -hide_banner \
    -f decklink -i 'DeckLink Mini Recorder (2)' \
    -r 25000/1000 -format_code pal -maxrate 1500k -bufsize 3000k \
    -c:v h264 -preset medium -profile:v high -pix_fmt yuv420p \
    -bf 2 -g 25 -coder 1 -crf 18 -force_key_frames "expr:gte(t,n_forced*2)" \
    -vf crop=704:560:8:10,yadif,scale=720:408 \
    -c:a libfdk_aac -ac 2 -ar 48000 -profile:a aac_low -b:a 128k \
    -f segment -strftime 1 -segment_time 3600 -segment_atclocktime 1 \
    -reset_timestamps 1 -segment_format_options movflags=+faststart \
    $HOME/$FOLDER/Russia24_%Y%m%d_%H-%M.mp4

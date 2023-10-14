#!/bin/bash
export LC_CTYPE=ru_RU.UTF-8
SRC=/mnt/pegas33/VIDEO/AIR/904_Вести
DST=/home/public/out/reel
EXT=mxf
TXT=list.txt
NAME=904_Вести-сурдо-$(date +%Y%m%d)

if [ ! -d $SRC ]; then
  mount /mnt/pegas33
fi

if [ -f /tmp/list.txt ]; then
  rm /tmp/list.txt
fi

find $SRC -type f -name "*.xmp" -exec rm -f {} \;
find $SRC -type f -name "*surdo*.*" -mmin +$((60 * 8)) -exec rm -f {} \;

if [[ $(find $SRC -maxdepth 1 -type f -name "*surdo*.*" -mmin +2 | wc -l) -ne 2 ]]; then
  echo Source files is not ready!
elif [[ -f "$DST/$NAME.mp4" ]]; then
  echo Destination file exist!
else
  for f in $SRC/*surdo*.*; do
    echo "file '$f'" >>/tmp/$TXT
  done

  if ffmpeg -v fatal -f concat -safe 0 -i /tmp/$TXT -c copy "/tmp/$NAME.$EXT" -y &&
    ffmpeg -v fatal -i "/tmp/$NAME.$EXT" -i /root/script/surdo/logo.tga -y -map_metadata -1 \
      -filter_complex "[0:v]yadif,scale=1280:720[v]; \
      [1:v]colorchannelmixer=aa=0.85,scale=1280:720[l];[v][l]overlay" \
      -c:v h264 -preset slower -profile:v high -pix_fmt yuv420p \
      -bf 2 -g 25 -coder 1 -crf 18 -force_key_frames "expr:gte(t,n_forced*2)" \
      -c:a aac -ac 2 -ar 48000 -profile:a aac_low -b:a 128k \
      -strict -2 -movflags +faststart "$DST/$NAME.mp4"; then

    MSG="Файл $(echo '\\gtrk22\out\reel\')"$NAME.mp4" готов к выкладке"
    echo $MSG | sendxmpp -f /root/script/.sendxmpprc USER1@EXAMPLE.COM
    echo $MSG | sendxmpp -f /root/script/.sendxmpprc USER2@EXAMPLE.COM

    ONG=Russia24-$(date +%Y%m%d)_12-00

    cd '/mnt/pegas33/Перегоны/!!!!!  ВСЕ ОСТАЛЬНОЕ ЗДЕСЬ!!!!!!/ОНГ/Surdo/'

    ffmpeg -v fatal -i "/tmp/$NAME.$EXT" -i /root/script/surdo/logo.tga -y -map_metadata -1 \
      -filter_complex "[0:v]yadif,scale=480:272[v]; \
      [1:v]colorchannelmixer=aa=0.85,scale=480:272[l];[v][l]overlay" \
      -c:v h264 -preset veryslow -pix_fmt yuv420p \
      -c:a aac -ac 2 -ar 44100 -profile:a aac_low -b:a 64k \
      -strict -2 -movflags +faststart "./$ONG.mp4"

    for f in ./*; do
      touch -a "$f"
    done

    if [ -f /tmp/$NAME.$EXT ]; then
      rm /tmp/$NAME.$EXT
    fi

    if [ -f /tmp/list.txt ]; then
      rm /tmp/list.txt
    fi

  else
    MSG="Опять какая-то фигня с сурдопереводом!"
    echo $MSG | sendxmpp -f /root/script/.sendxmpprc USER1@EXAMPLE.COM
    exit 1
  fi

fi

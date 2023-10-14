#!/bin/bash
#
# crontab
# 30 21 * * 1-5 /root/script/sibir24.sh > /dev/null #Sibir24
#
export LC_CTYPE=ru_RU.UTF-8

mount /mnt/xds1000

dir=/home/public/out/tmp
file="$(find /mnt/xds1000 -iname "*.mxf" -size +4G -size -8G -mmin -60 | head -1)"
name="$(date +%Y%m%d_Altai_Vesti_prime.mxf)"
rcp=(USER1@EXAMPLE.COM USER2@EXAMPLE.COM USER3@EXAMPLE.COM USER4@EXAMPLE.COM)

if [ -f "$file" ]; then
  rsync -a $file $dir/$name
  ffmpeg -v fatal -y -i "$dir/$name" -map_metadata -1 -map 0:0 -map 0:1 \
    -c:v h264 -s hd1080 -preset slow -profile:v high \
    -pix_fmt yuv420p -bf 2 -g 25 -coder 1 -crf 21 -vf yadif \
    -force_key_frames "expr:gte(t,n_forced*2)" -movflags faststart \
    -c:a aac -ac 2 -ar 48000 -profile:a aac_low -b:a 320k -strict -2 \
    "$dir/${name%.*}".mp4
  rm "$dir/$name"

  if lftp -u USER,PASSWORD SERVER -e \
    "put -c "$dir/${name%.*}".mp4; bye;"; then
    TXT="Вести-прайм $(echo '\\EXAMPLE\out\tmp\')${name%.*}.mp4 отправлен в Обмен-Сибирь"
    for i in ${rcp[@]}; do
      echo $TXT | sendxmpp -f /root/script/.sendxmpprc $i
    done
  else
    TXT='Не удалось отправить Вести-прайм в Обмен-Сибирь!'
    for i in ${rcp[@]}; do
      echo $TXT | sendxmpp -f /root/script/.sendxmpprc $i
    done
  fi

else
  TXT='Не удалось получить Вести-прайм с Sony XDS-1000! Выключен аппарат?'
  for i in ${rcp[@]}; do
    echo $TXT | sendxmpp -f /root/script/.sendxmpprc $i
  done
fi

umount -f /mnt/xds1000

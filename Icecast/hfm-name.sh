#!/bin/bash

#########################
## Metadata to Icecast ##
#########################

## Crontab:
## * * * * * /root/script/hfm-name.sh > /dev/null 2>&1

ADMIN=LOGIN
PASSWORD=PASSWORD

if [ ! -f /mnt/rds/cur_playing.xml ]; then
  mount /mnt/rds
fi

for i in {1..29}; do

    NAME=$(cat /mnt/rds/cur_playing.xml |
        /usr/bin/awk 'BEGIN{FS="<.?NAME>"}{print $2}')

    ARTIST=$(cat /mnt/rds/cur_playing.xml |
        /usr/bin/awk 'BEGIN{FS="<.?ARTIST>"}{print $2}')

    if [[ -z "$NAME" || -z "$ARTIST" ]]; then
        SONG=Радио+«Heart+FM»+Барнаул+-+Тел.:+\(3852\)+55-10-59,+e-mail:+radio@heartfm.ru
    else
        SONG=$(echo "$ARTIST - $NAME" | sed "s/&amp;//g" | sed "s/  */ /g" | sed "s/ /+/g")
    fi

    curl -u $ADMIN:$PASSWORD -s \
        "http://127.0.0.1:8001/$ADMIN/metadata?mount=/heartfm&mode=updinfo&song=$SONG"

    sleep 2

done

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/mayak&mode=updinfo&song=Радио+«Маяк»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10"

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/russia&mode=updinfo&song=«Радио+России»+Алтай+-+Телефон+рекламной+службы:+(3852)+68-50-10"

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/vesti&mode=updinfo&song=Радио+«Вести+ФМ»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10"

#!/bin/bash

#########################
## Metadata to Icecast ##
#########################

## Crontab:
## * * * * * /root/script/hfm-name.sh > /dev/null 2>&1

ADMIN=admin
PASSWORD=password
NOSONG='Радио+«Heart+FM»+Барнаул+-+Тел.:+\(3852\)+55-10-59,+e-mail:+radio@heartfm.ru'
MAYAK='Радио+«Маяк»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10'
RUSSIA='«Радио+России»+Алтай+-+Телефон+рекламной+службы:+(3852)+68-50-10'
VESTI='Радио+«Вести+ФМ»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10'

if [ ! -f /mnt/rds/cur_playing.xml ]; then
    mount /mnt/rds
fi

for i in {1..29}; do

    NAME=$(cat /mnt/rds/cur_playing.xml |
        /usr/bin/awk 'BEGIN{FS="<.?NAME>"}{print $2}')

    ARTIST=$(cat /mnt/rds/cur_playing.xml |
        /usr/bin/awk 'BEGIN{FS="<.?ARTIST>"}{print $2}')

    if [[ -z "$NAME" || -z "$ARTIST" ]]; then
        SONG=$NOSONG
    else
        SONG=$(echo "$ARTIST - $NAME" | sed "s/&amp;//g" | sed "s/  */ /g" | sed "s/ /+/g")
    fi

    curl -u $ADMIN:$PASSWORD -s \
        "http://127.0.0.1:8001/$ADMIN/metadata?mount=/heartfm&mode=updinfo&song=$SONG"

    sleep 2

done

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/mayak&mode=updinfo&song=$MAYAK"

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/russia&mode=updinfo&song=$RUSSIA"

curl -u $ADMIN:$PASSWORD -s \
    "http://127.0.0.1:8001/$ADMIN/metadata?mount=/vesti&mode=updinfo&song=$VESTI"

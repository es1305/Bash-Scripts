#!/bin/bash

#########################
## Metadata to Icecast ##
#########################

## Crontab:
## * * * * * /root/scripts/ice-meta.sh > /dev/null 2>&1

ADMIN=admin
PASSWORD=password
HEARTFM='Радио+«Heart+FM»+Барнаул+-+Тел.:+(3852)+55-10-59,+e-mail:+radio@heartfm.ru'
MAYAK='Радио+«Маяк»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10'
RUSSIA='«Радио+России»+Алтай+-+Телефон+рекламной+службы:+(3852)+68-50-10'
VESTI='Радио+«Вести+ФМ»+Барнаул+-+Телефон+рекламной+службы:+(3852)+68-50-10'

# Process Heart FM
for i in {1..29}; do
    RDS=$(smbclient -d 0 -A /root/.smbcredentials //heart-air-01/xml -c 'get cur_playing.xml -')
    NAME=$(awk -F'<.?NAME>' '{print $2}' <<< "$RDS")
    ARTIST=$(awk -F'<.?ARTIST>' '{print $2}' <<< "$RDS")
    if [[ -z "$NAME" || -z "$ARTIST" ]]; then
        SONG=$HEARTFM
    elif grep -Ei '\$|промо|джингл|новости|погода|блок|реклама' <<< "$ARTIST"; then
        SONG=$HEARTFM
    else
        SONG=$(echo "$ARTIST - $NAME" |
            sed "s/&amp;\|feat\./ft\./g" | sed "s/  */ /g" | sed "s/ /+/g")
    fi
    curl -u $ADMIN:$PASSWORD -s \
        "http://127.0.0.1/$ADMIN/metadata?mount=/heartfm&mode=updinfo&song=$SONG"
    sleep 2
done

# Process all others
for STATION in mayak russia vesti; do
    SONG_VAR=$(echo "${STATION^^}")
    curl -u $ADMIN:$PASSWORD -s \
        "http://127.0.0.1/$ADMIN/metadata?mount=/$STATION&mode=updinfo&song=${!SONG_VAR}"
done

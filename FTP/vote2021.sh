#!/bin/bash
export LC_CTYPE=ru_RU.UTF-8
SRV=ftp.example.com
USER=USER
PASS=PASSWORD
SRC=FOLDER
DST=/mnt/pegas33/$SRC
RCP=(USER1@EXAMPLE.COM USER2@EXAMPLE.COM USER3@EXAMPLE.COM USER4@EXAMPLE.COM)

lftp -u $USER,$PASS -e "set ftp:charset cp1251; mirror -c -x Thumbs.db $SRC $DST; bye;" $SRV
find $DST \( -iname "Thumbs.db" -or -iname "*DS_Store*" -or -iname "._*" \) -exec rm {} \;
find $DST -type f -mmin -$((60 * 2)) | awk 'sub("$", "\r")' >/tmp/newfiles.txt

F=$(cat /tmp/newfiles.txt)

if [ -z "$F" ]; then
  echo "No new files"
else
  N=$(cat /tmp/newfiles.txt | wc -l)
  MSG1="$(cat /tmp/newfiles.txt | awk -F"$SRC/" '{print $2}' | sed 's/\//\\/g')"
  MSG2="Выборы 2021: $N новых файлов в папке $(echo "\\pegas33\D\$SRC\")"
  for i in ${RCP[@]}; do
    echo $MSG1 | sendxmpp -f /root/script/.sendxmpprc $i
    echo $MSG2 | sendxmpp -f /root/script/.sendxmpprc $i
  done
fi

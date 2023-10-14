#!/bin/bash
export LC_CTYPE=ru_RU.UTF-8
SRC=/mnt/pegas33/VIDEO/AIR/904_Вести/VESTI_9_00
DST=/home/public/out/reel
RCP=(USER1@EXAMPLE.COM USER2@EXAMPLE.COM USER3@EXAMPLE.COM USER4@EXAMPLE.COM)

if [ ! -d $SRC ]; then
  mount /mnt/pegas33
fi

find $SRC -type f -name "*.mxf" -mmin +$((60 * 8)) -exec rm -f {} \;

IFS=$'\n'
array=($(find $SRC -type f -name "*.mxf" -mmin +2))

echo "Number of items to convert: ${#array[*]}"

for ix in ${!array[*]}; do
  i=$(printf "%s\n" "${array[$ix]}")
  let "n=$ix + 1"
  echo
  echo -e "Prepare and convert file number $n:\n"$i""

  if [[ -f "$DST/$(basename ${i%.*})".mp4 ]]; then
    echo "Destination file exist:"
    echo ""$DST/$(basename ${i%.*})".mp4"
  else
    ffmpeg -v fatal -i "$i" -map_metadata -1 -map 0:0 -map 0:1 \
      -c:v h264 -s hd480 -pix_fmt yuv420p -bf 2 -g 25 -coder 1 \
      -c:a aac -ac 2 -ar 48000 -profile:a aac_low -b:a 128k \
      -strict -2 -movflags +faststart "$DST/$(basename ${i%.*})".mp4

    SBJ="Вести-Алтай утренний выпуск часть $n"
    TRD=$(echo "$(basename ${i%.*}).mp4" | sed s/' '/'%20'/g)
    TXT=$(echo -e "Файл для просмотра:\nhttp://EXAMPLE.COM/out/reel/$TRD")
    for i in ${RCP[@]}; do
      echo "$TXT" | mail -s "$SBJ"
    done
  fi
done

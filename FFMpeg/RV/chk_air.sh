#!/bin/bash

# Crontab:
# * * * * * /root/script/chk_air.sh > /dev/null

home=/root/script/air

for script in $home/*.sh; do
  name=$(basename $script)
  if [[ $(pgrep $name) -gt 0 ]]; then
    echo "$name already running!"
    echo "Process ID $(pgrep $name)"
  else
    $script &
  fi
done

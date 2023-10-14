#!/bin/bash
if [[ $(pgrep r24.sh) -gt 0 ]]
  then {
    echo "r24.sh already running!"
    echo "Process ID `pgrep r24.sh`"
  }
  else {
    /home/eugene/script/r24.sh
  }
fi

#!/bin/bash
if [[ $(pgrep r1.sh) -gt 0 ]]; then
    echo "Script r1.sh already running!"
    echo "Process ID $(pgrep r1.sh)"
else
    /root/script/r1.sh
fi

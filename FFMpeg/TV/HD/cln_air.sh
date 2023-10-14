#!/bin/bash
HOME=/srv
TIME=-mtime\ +15

find $HOME -type f $TIME -exec rm -f {} \;
find $HOME -depth -mindepth 1 -type d -empty -exec rmdir {} \;

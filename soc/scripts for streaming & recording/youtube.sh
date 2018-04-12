#!/bin/bash

STREAM_KEY=17mp-vm1y-kpzd-2998
URL=rtmp://a.rtmp.youtube.com/live2/$STREAM_KEY

ffmpeg -f concat -i list.txt \
-f alsa -i default -map 0:v -map 1:a \
-c:v copy -c:a aac -ar 44100 -b:a 96k \
-f flv $URL

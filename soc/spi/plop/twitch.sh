#!/bin/bash

STREAM_KEY=live_205865829_ICeYXGi2sw5IntQ2uQZavJ9MqWjxDo
URL=rtmp://live.twitch.tv/app/$STREAM_KEY

ffmpeg -f concat -i list.txt \
-f alsa -i FPGA -map 0:v -map 1:a \
-c:v copy -b:a 96k -ar 44100 -c:a libmp3lame \
-f flv $URL

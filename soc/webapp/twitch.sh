#!/bin/bash

avconv -f concat -i list.txt -f alsa -i dsnoop:CARD=FPGA,DEV=1 -map 0:v -map 1:a -c:v copy -c:a aac -ar 44100 -b:a 96k -f flv rtmp://live.twitch.tv/app/live_205865829_ICeYXGi2sw5IntQ2uQZavJ9MqWjxDo

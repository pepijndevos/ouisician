#!/bin/bash

jackd -m -p 32 -d alsa -d hw:CARD=FPGA,DEV=1 -S &
sleep 1
alsa_out 2>&1 > /dev/null &
sleep 1
scsynth -u 4555 &
sleep 1
jack_connect SuperCollider:out_1 alsa_out:playback_1
jack_connect SuperCollider:out_2 alsa_out:playback_2
jack_connect system:capture_1 SuperCollider:in_1
jack_connect system:capture_2 SuperCollider:in_2

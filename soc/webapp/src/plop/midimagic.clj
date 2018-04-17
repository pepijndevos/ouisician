(ns plop.midimagic
  (:import 	[java.io IOException]
			[java.lang Process]
  			[java.lang ProcessBuilder]))
			
(defn startmidi []
	(def fluidsynth-cmd "fluidsynth -a pulseaudio -m alsa_seq /home/pi/ChoriumRevA/ChoriumRevA.SF2 -g 5")
	(def pb-fluidsynth (ProcessBuilder. (list "/bin/bash" "-c" fluidsynth-cmd)))
	(def process-fluidsynth (.start pb-fluidsynth))
	(Thread/sleep 1000)
	(def aconnect-cmd "aconnect 24:0 128:0")
	(def pb-aconnect (ProcessBuilder. (list "/bin/bash" "-c" aconnect-cmd)))
	(def process-aconnect (.start pb-aconnect)))
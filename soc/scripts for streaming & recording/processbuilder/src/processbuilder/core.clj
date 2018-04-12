(ns processbuilder.core
  (:import 	[java.io IOException]
			[java.lang Process]
  			[java.lang ProcessBuilder]))
		
(def platform "live.twitch.tv/app/")
(def streamkey "live_205865829_ICeYXGi2sw5IntQ2uQZavJ9MqWjxDo")		
(def bitrate "96k")
(def string (str "ffmpeg -f concat -i list.txt -f alsa -i pulse -map 0:v -map 1:a -c:v copy -b:a" bitrate "-ar 44100 -c:a aac -f flv rtmp://" platform streamkey))

(def pb (ProcessBuilder. (list "/bin/bash" "-c" string)))

(defn startstream []
	(def process (.start pb)))
	
(defn stopstream []
	(.destroy process))

(startstream)
(Thread/sleep 30000)
(stopstream)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (while true
	(Thread/sleep 1000)))


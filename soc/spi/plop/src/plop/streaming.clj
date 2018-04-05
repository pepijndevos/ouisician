(ns plop.streaming
  (:import 	[java.io IOException]
			[java.lang Process]
  			[java.lang ProcessBuilder]))
			
(def platform "live.twitch.tv/app/")
(def streamkey "live_205865829_ICeYXGi2sw5IntQ2uQZavJ9MqWjxDo")		
(def bitrate "96k")
(def string-stream (str "ffmpeg -f concat -i list.txt -f alsa -i pulse -map 0:v -map 1:a -c:v copy -b:a" bitrate "-ar 44100 -c:a aac -f flv rtmp://" platform streamkey))

(def string-record (str "arecord -c 2 -f S16_LE -r 44100 -t wav -D pulse oui.wav"))

(def pb-stream (ProcessBuilder. (list "/bin/bash" "-c" string-stream)))
(def pb-record (ProcessBuilder. (list "/bin/bash" "-c" string-record)))

(defn startstream []
	(def process-stream (.start pb-stream))
	(println "Starting stream"))
	
(defn stopstream []
	(.destroy process-stream)
	(println "Stopping stream"))

(defn startrecording []
	(def process-record (.start pb-record))
	(println "Starting recording"))

(defn stoprecording []
	(.destroy process-record)
	(println "Stopping recording"))
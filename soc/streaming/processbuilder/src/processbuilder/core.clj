(ns processbuilder.core
  (:import 	[java.io IOException]
			[java.lang Process]
  			[java.lang ProcessBuilder]))
			
(def string "ffmpeg -f concat -i list.txt -i roll.mp3 -map 0:v -map 1:a -c:v copy -b:a 96k -ar 44100 -c:a libmp3lame -f flv rtmp://live.twitch.tv/app/live_205865829_ICeYXGi2sw5IntQ2uQZavJ9MqWjxDo")

(def pb (ProcessBuilder. (list "/bin/bash" "-c" string)))
(.start pb)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!")
  (while true
	(Thread/sleep 1000)))


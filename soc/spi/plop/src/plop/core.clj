(ns plop.core
	(:use [plop.sound :only [start channels]]
        [overtone.core :only [ctl]]
        [compojure.route :only [files resources not-found]]
        [compojure.handler :only [site]] ; form, query params decode; cookie; session, etc
        [compojure.core :only [defroutes GET POST DELETE ANY context]]
        [ring.util.response :only [redirect]]
        org.httpkit.server)
	(:require [clojure.data.json :as json])
	(:import 	[java.io IOException]
  			[com.pi4j.io.spi SpiChannel SpiDevice SpiFactory SpiMode]
  			[com.pi4j.util Console]))
			
(defn printSPIsettings[& {:keys [chan speed mode]
							:or {chan (.getChannel SpiChannel/CS0)
								speed (SpiDevice/DEFAULT_SPI_SPEED)
								mode (.getMode SpiDevice/DEFAULT_SPI_MODE)}}]
		(println "Using:")
		(println "- Channel" chan)
		(println "- Speed" speed)
		(println "- Mode" mode))

(defn setSPIsettings[& {:keys [chan speed mode]
							:or {chan (.getChannel SpiChannel/CS0)
								speed (SpiDevice/DEFAULT_SPI_SPEED)
								mode (.getMode SpiDevice/DEFAULT_SPI_MODE)}}]
		
		(def spi (SpiFactory/getInstance (SpiChannel/getByNumber chan) speed (SpiMode/getByNumber mode)))
		(printSPIsettings :chan chan :speed speed :mode mode))
			


(setSPIsettings :mode 1)
			
(defn socket-handler [req]
  (with-channel req channel
    (on-close channel (fn [status]
                        (println "channel closed")))
    (on-receive channel (fn [data]
                          (let [{id "id", val "val", chan "chan"} (json/read-str data)
                                inst (get @channels chan)
                                param (keyword id)]
							(let [packet (byte-array [(byte 0x00) chan id val])]
								(println "TX" (seq packet))
								(def rx (.write spi packet))
								(println "RX" (seq rx))
								;(ctl inst param val)
								;(prn inst param val)
								))))))

(defroutes all-routes
  (GET "/" [] (redirect "index.html"))
  (GET "/ws" [] socket-handler)     ;; websocket
  (resources "/")
  (not-found "<p>Page not found.</p>")) ;; all other, return 404

(start)
(run-server (site #'all-routes) {:port 8080})

(def console (Console.))
(while (.isRunning console)
	
	(Thread/sleep 20))
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)
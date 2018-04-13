(ns plop.core
	(:use 
		;[plop.sound :only [osc-start channels]]
		[plop.streaming]
		[plop.spi-handler]
		[plop.midimagic]
        ;[overtone.core :only [ctl]]
        [compojure.route :only [files resources not-found]]
        [compojure.handler :only [site]] ; form, query params decode; cookie; session, etc
        [compojure.core :only [defroutes GET POST DELETE ANY context]]
        [ring.util.response :only [redirect]]
        org.httpkit.server)
	(:require [clojure.data.json :as json])
	(:import [com.pi4j.util Console]
            java.io.File))


(defn my-ls [d channel]
  ;(println "Files in " (.getName d))
  (doseq [f (.listFiles d)]
    (if (.isDirectory f)
      (print "d ")
      (print "- "))
    (println (.getName f))
    (let [filepath (str "recordings/" (.getName f))]
    (let [msg (json/write-str {:id "wav" :display filepath})]
        (send! channel msg)
      ))
))

(defn listrecordings [channel]
  (my-ls (File. "./resources/public/recordings") channel)
  )

(defonce channels (atom #{}))

(defn update-clients [id numid chan display]
		(def msg (json/write-str {:id id :numid numid :chan chan :display display}))

		(doseq [channel @channels]
 			(send! channel msg))
	)

(defn handle-msg [data]
	(def lastdata data)
  (let [{numid "numid", id "id", val "val", chan "chan", platform "platform"} (json/read-str data)]
      (if (and (== 0 (compare id "streaming")) (== 1 numid))
        (def display (startstream platform)))
      (if (and (== 0 (compare id "streaming")) (== 0 numid))
        (def display (stopstream)))
      (if (and (== 0 (compare id "recording")) (== 1 numid))
        (def display (startrecording)))
      (if (and (== 0 (compare id "recording")) (== 0 numid))
        (def display (stoprecording)))
      (if (>= chan 1) ;only send sound controls to FPGA
      	(do (def display val)
  		(SPIhandler id chan numid val)))

  	(update-clients id numid chan display)))
        

(defn connect! [channel]
 (println "channel open")
 (swap! channels conj channel)
  (if (boolean (bound? #'msg))
 	(send! channel msg)))

(defn disconnect! [channel status]
 (println "channel closed:" status)
 (swap! channels #(remove #{channel} %)))

			
(defn socket-handler [req]
  (with-channel req channel
    (connect! channel)
    (listrecordings channel)
    (on-close channel (partial disconnect! channel))
    (on-receive channel #(handle-msg %))))

(defroutes all-routes
  (GET "/" [] (redirect "index.html"))
  (GET "/ws" [] socket-handler)     ;; websocket
  (resources "/")
  (not-found "<p>Page not found.</p>")) ;; all other, return 404

;(osc-start)
(startmidi)
(run-server (site #'all-routes) {:port 8080})

(def console (Console.))
(while (.isRunning console)
	
	(Thread/sleep 2000))
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)

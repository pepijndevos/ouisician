(ns plop.core
	(:use 
		;[plop.sound :only [osc-start channels]]
		[plop.streaming]
		[plop.spi-handler]
        ;[overtone.core :only [ctl]]
        [compojure.route :only [files resources not-found]]
        [compojure.handler :only [site]] ; form, query params decode; cookie; session, etc
        [compojure.core :only [defroutes GET POST DELETE ANY context]]
        [ring.util.response :only [redirect]]
        org.httpkit.server)
	(:require [clojure.data.json :as json])
	(:import [com.pi4j.util Console]
            java.io.File))

(defonce channels (atom #{}))

(defn my-ls [d channel]
  (println "Files in " (.getName d))
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


			
(defn socket-handler [req]
  (with-channel req channel
    (listrecordings channel)
    (on-close channel (fn [status]
                        (println "channel closed")))
    (on-receive channel (fn [data]
                          (let [{numid "numid", id "id", val "val", chan "chan", platform "platform"} (json/read-str data)
                                ;inst (get @channels chan)
                                param (keyword id)]

              

							(if (and (== 0 (compare id "streaming")) (== 1 numid))
								(def display (startstream platform)))
							(if (and (== 0 (compare id "streaming")) (== 0 numid))
								(stopstream))
              (if (and (== 0 (compare id "recording")) (== 1 numid))
                (def display (startrecording)))
              (if (and (== 0 (compare id "recording")) (== 0 numid))
                (def display (stoprecording)))
							(if (>= chan 1) ;only send sound controls to FPGA
                (SPIhandler chan numid val))
								;(SPItransfer chan numid val))
								;(ctl inst param val)
								;(prn inst param val)
              (def msg (json/write-str {:id id :numid numid :display display}))
              (send! channel msg)
								)))))

(defroutes all-routes
  (GET "/" [] (redirect "index.html"))
  (GET "/ws" [] socket-handler)     ;; websocket
  (resources "/")
  (not-found "<p>Page not found.</p>")) ;; all other, return 404

;(osc-start)
(run-server (site #'all-routes) {:port 8080})

(def console (Console.))
(while (.isRunning console)
	
	(Thread/sleep 2000))
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)
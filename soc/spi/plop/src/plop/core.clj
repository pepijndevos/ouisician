(ns plop.core
	(:use 
		;[plop.sound :only [osc-start channels]]
		[plop.streaming]
		[plop.spi]
        ;[overtone.core :only [ctl]]
        [compojure.route :only [files resources not-found]]
        [compojure.handler :only [site]] ; form, query params decode; cookie; session, etc
        [compojure.core :only [defroutes GET POST DELETE ANY context]]
        [ring.util.response :only [redirect]]
        org.httpkit.server)
	(:require [clojure.data.json :as json])
	(:import 	[java.io IOException]
  			[com.pi4j.io.spi SpiChannel SpiDevice SpiFactory SpiMode]
  			[com.pi4j.util Console]))
			
(defn socket-handler [req]
  (with-channel req channel
    (on-close channel (fn [status]
                        (println "channel closed")))
    (on-receive channel (fn [data]
                          (let [{numid "numid", id "id", val "val", chan "chan"} (json/read-str data)
                                ;inst (get @channels chan)
                                param (keyword id)]
							(if (and (== 0 (compare id "streaming")) (== 1 val))
								(startstream))
							(if (and (== 0 (compare id "streaming")) (== 0 val))
								(stopstream))
							(SPItransfer chan numid val)
								;(ctl inst param val)
								;(prn inst param val)
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
	
	(Thread/sleep 20))
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)
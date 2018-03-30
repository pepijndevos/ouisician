(ns synth.core
  (:use [synth.sound :only [start channels]]
        [overtone.core :only [ctl]]
        [compojure.route :only [files resources not-found]]
        [compojure.handler :only [site]] ; form, query params decode; cookie; session, etc
        [compojure.core :only [defroutes GET POST DELETE ANY context]]
        [ring.util.response :only [redirect]]
        org.httpkit.server)
  (:require [clojure.data.json :as json])
  (:gen-class))

(defn socket-handler [req]
  (with-channel req channel
    (on-close channel (fn [status]
                        (println "channel closed")))
    (on-receive channel (fn [data]
                          (let [{id "id", val "val", chan "chan"} (json/read-str data)
                                inst (get @channels chan)
                                param (keyword id)]
                            (ctl inst param val)
                            (prn inst param val))))))

(defroutes all-routes
  (GET "/" [] (redirect "index.html"))
  (GET "/ws" [] socket-handler)     ;; websocket
  (resources "/")
  (not-found "<p>Page not found.</p>")) ;; all other, return 404

  
(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (start)
  (run-server (site #'all-routes) {:port 8080}))

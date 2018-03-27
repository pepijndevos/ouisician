(ns hello.core
  (:use 'ring.adapter.jetty)
  (:use 'hello.core))

(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/plain"}
   :body "Hello World"})

(run-jetty handler {:port 8080})

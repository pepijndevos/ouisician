(ns hello.core)

(response "hello world")
(defn handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Hello World"})

; (defn what-is-my-ip [request])
;   {:status 200
;     :headers {"Content-Type" "text/plain"}
;     :body (:remote-addr request)
;   })

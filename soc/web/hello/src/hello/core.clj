; (ns hello.core)

; (ns ring.example.hello-world-2
 (ns hello 
  (:use ring.util.response
        ring.adapter.jetty))

(defn handler [request]
  (-> (response "Hello World")
      (content-type "text/plain")))

(run-jetty handler {:port 8080})
; (response "hello world")
; (defn handler [request]
;   {:status 200
;    :headers {"Content-Type" "text/html"}
;    :body "Hello World"})

; (defn what-is-my-ip [request])
;   {:status 200
;     :headers {"Content-Type" "text/plain"}
;     :body (:remote-addr request)
;   })

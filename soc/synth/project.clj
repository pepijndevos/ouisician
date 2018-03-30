(defproject synth "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [overtone "0.10.3"]
                 [http-kit "2.2.0"]
                 [compojure "1.6.0"]
                 [org.clojure/data.json "0.2.6"]
                 [javax.servlet/servlet-api "2.5"]]
  :main ^:skip-aot synth.core
  :target-path "target/%s"
  :repl-options { :timeout 120000 }
  :profiles {:uberjar {:aot :all}})

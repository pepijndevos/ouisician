(ns synth.core
  (:use overtone.core)
  (:gen-class))

(connect-external-server 4555)

(def server (osc-server 44100 "osc-clj"))

(definst microphone [vol 1 pan 0 chan 0 mix 0.33 room 0.5 damp 0.5]
  (pan2 (free-verb (sound-in chan) mix room damp) pan vol))

(defn control-param [ins param min max msg]
  (let [raw (first (:args msg))
        scaled (scale-range raw 0 1 min max)]
    (ctl ins param scaled)))

(defn start-mic [ch volpath panpath mixpath roompath damppath]
  (let [ins (microphone 1 0 ch)]
    (osc-handle server volpath
      (partial control-param ins :vol 0 1))
    (osc-handle server panpath
      (partial control-param ins :pan -1 1))
    (osc-handle server mixpath
      (partial control-param ins :mix 0 1))
    (osc-handle server roompath
      (partial control-param ins :room 0 1))
    (osc-handle server damppath
      (partial control-param ins :damp 0 1))))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (zero-conf-on)
  (osc-listen server (fn [msg] (println msg)) :debug)
  ;(start-mic 0 "/1/fader1" "/1/fader2" "/1/fader3" "/1/fader4" "/1/fader5")
  (start-mic 1 "/1/fader1" "/1/fader2" "/1/fader3" "/1/fader4" "/1/fader5")
  (println "Running"))

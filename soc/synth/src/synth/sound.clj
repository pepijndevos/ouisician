(ns synth.sound
  (:use overtone.core))

(connect-external-server 4555)

(def channels (atom {}))

(definst microphone [vol 1 pan 0 chan 0 mix 0.33 room 0.5 damp 0.5]
  (pan2 (free-verb (sound-in chan) mix room damp) pan vol))

(defn control-param [ins param min max msg]
  (let [raw (first (:args msg))
        scaled (scale-range raw 0 1 min max)]
    (ctl ins param scaled)))

(defn start-mic [server ch volpath panpath mixpath roompath damppath]
  (let [ins (microphone 1 0 ch)]
    (swap! channels assoc ch ins)
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

(defn numbered-file [fname]
  (->> (range)
    (map #(java.io.File. (format fname %)))
    (remove #(.exists %))
    (first)))

(defn record [server btn]
  (osc-handle server btn
    (fn [{[state] :args}]
      (if (> state 0.5)
        (recording-start (numbered-file "output%d.wav"))
        (recording-stop)))))

(defn start []
  (let [server (osc-server 44100 "osc-clj")]
    (zero-conf-on)
    (osc-listen server (fn [msg] (println msg)) :debug)
    (start-mic server 0 "/1/fader1" "/1/fader2" "/1/fader3" "/1/fader4" "/1/fader5")
    ;(start-mic server 1 "/1/fader1" "/1/fader2" "/1/fader3" "/1/fader4" "/1/fader5")
    (record server "/1/toggle1")
    (println "Running")))

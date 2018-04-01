(ns blob.core
  (:import 	[java.io IOException]
  			[com.pi4j.io.spi SpiChannel SpiDevice SpiFactory]
  			[com.pi4j.util Console]))

(defn printSPIsettings
	([]
		(println "Using default SPI settings:")
		(println "- Channel" (SpiChannel/CS0))
		(println "- Speed" (SpiDevice/DEFAULT_SPI_SPEED) "Hz")
		(println "- Mode" (.getMode SpiDevice/DEFAULT_SPI_MODE)))
	([chan]
		(println "Using:")
		(println "- Channel" chan)
		(println "- Speed" (SpiDevice/DEFAULT_SPI_SPEED) "Hz")
		(println "- Mode" (.getMode SpiDevice/DEFAULT_SPI_MODE)))
)

(defn setSPIsettings
	([]
		(printSPIsettings)
		(def spi (SpiFactory/getInstance (SpiChannel/CS0)))
		)
	([chan]
		(printSPIsettings chan)
		(def spi (SpiFactory/getInstance (SpiChannel/getByNumber chan))
		))
)

(def packet (byte-array [(byte 0x01) (byte 0x02) (byte 0x03)]))

(setSPIsettings 0)

(def console (Console.))
(while (.isRunning console)
	(println "TX" (seq packet))
	(def rx (.write spi packet))
	(println "RX" (seq rx))
	(Thread/sleep 250)
)
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)

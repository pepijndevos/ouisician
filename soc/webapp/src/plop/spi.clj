(ns plop.spi
	(:import 	[java.io IOException]
  			[com.pi4j.io.spi SpiChannel SpiDevice SpiFactory SpiMode]
  			[com.pi4j.util Console]))

(defn printSPIsettings[& {:keys [chan speed mode]
							:or {chan (.getChannel SpiChannel/CS0)
								speed (SpiDevice/DEFAULT_SPI_SPEED)
								mode (.getMode SpiDevice/DEFAULT_SPI_MODE)}}]
		(println "Using:")
		(println "- Channel" chan)
		(println "- Speed" speed)
		(println "- Mode" mode))

(defn setSPIsettings[& {:keys [chan speed mode]
							:or {chan (.getChannel SpiChannel/CS0)
								speed (SpiDevice/DEFAULT_SPI_SPEED)
								mode (.getMode SpiDevice/DEFAULT_SPI_MODE)}}]
		
		(def spi (SpiFactory/getInstance (SpiChannel/getByNumber chan) speed (SpiMode/getByNumber mode)))
		(printSPIsettings :chan chan :speed speed :mode mode))
			
(setSPIsettings :mode 1)

(defn SPItransfer [packet]
		(println "TX" (seq packet))
		(def rx (.write spi packet))
		(println "RX" (seq rx))
		)
(ns blob.core
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

(defn getByte [n long]
	(bit-shift-right long (* (- n 1) 8)))

(defn getByteArray[long]
		(byte-array [(getByte 4 long) (getByte 3 long) (getByte 2 long) long]))



(setSPIsettings :mode 1)

(def filterdata (getByteArray 4294967295))

(def byte-arrays [(byte-array [0 1]) filterdata])

(def packet (byte-array (for [ar byte-arrays i ar] i)))

(def console (Console.))
(while (.isRunning console)
	(println "TX" (seq packet))
	(def rx (.write spi packet))
	(println "RX" (seq rx))
	(Thread/sleep 20))
(.emptyLine console)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
)

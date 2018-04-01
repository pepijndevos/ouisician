(ns blob.core
  (:import 	[java.io IOException]
  			[com.pi4j.io.spi SpiChannel SpiDevice SpiFactory]
  			[com.pi4j.util Console]))

(defn printSPIdefaults[]
	(println "Default SPI settings:")
	(println (SpiChannel/CS0))
	(println (SpiDevice/DEFAULT_SPI_SPEED))
	(println (SpiDevice/DEFAULT_SPI_MODE))
)

(let [console (Console.)]
	(.title console (into-array String ["boo" "boo"]))
	(.promptForExit console)
	(printSPIdefaults)
	(def spi (SpiFactory/getInstance (SpiChannel/CS0)))
	(.write spi (byte-array [(byte 0x01) (byte 0x02)]))
	(while (.isRunning console)
		(Thread/sleep 1000)
	)
	(.emptyLine console)
)

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!")

)

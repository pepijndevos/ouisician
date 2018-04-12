(ns plop.spi-handler
	(:use 
		[plop.spi]
		[plop.filter-coeffs]))

(defn getByte [n long]
	"get nth byte of number"
	(bit-shift-right long (* (- n 1) 8)))

(defn getByteArray[long]
	"create byte array from number"
	(byte-array [(getByte 3 long) (getByte 2 long) long]))

(defn combineByteArrays 
	([chan filterid data]
	(let [byte-arrays [(byte-array [chan filterid]) data]]
		(def packet (byte-array (for [ar byte-arrays j ar] j))))
	)
	([chan filterid coeffid data]
	(let [byte-arrays [(byte-array [chan filterid coeffid]) data]]
		(def packet (byte-array (for [ar byte-arrays j ar] j))))
	)
	)

;NUMID
; 1 - EQUALIZER base
; 2 - EQUALIZER mid
; 3 - EQUALIZER terble

(defn calculateEQcoeffs [numid val]
	(println "-- Updating EQ coeffs --")
	;EQUALIZER base
	;[A0 A1 A2 B0 B1 B2]
	;(def coeffs (long-array [4096 -7965 3875 4185 -7958 3792]))
	(let [gain (/ val 2)]
		(println "Gain: " gain)
	(if (== numid 1)
		(def coeffs (base_shelve gain)))

	(if (== numid 2)
		(def coeffs (mid_peak gain)))

	(if (== numid 3)
		(def coeffs (treble_shelve gain))))
	
)

(defn sendEQpayload [chan numid n]
		(println "Coeff" n ":" (get coeffs n))
		(def filterdata (getByteArray (get coeffs n)))
		
		(combineByteArrays chan numid n filterdata)
		(SPItransfer packet))

(defn createEQpayload [chan numid val]

	(calculateEQcoeffs numid val)

	(dotimes [n 6]
		(sendEQpayload chan numid n))
)



(defn SPIhandler [chan numid val]
	(if (.contains [1 2 3] numid)
		(createEQpayload chan numid val)

		(do 
			(println "-- Other filter --")
			(let [packet (byte-array [chan numid (byte 0x00) (byte 0x00) (byte 0x00) val])]
			(SPItransfer packet)))
	)
)


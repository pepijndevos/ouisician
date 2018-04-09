(ns plop.filter-coeffs
	)

;EQUALIZER
(def pi Math/PI)
(defn pow2 [k] (Math/pow k 2))
(defn sqrt [k] (Math/sqrt k))

(def fsample 48000)
(def scale 12)

(defn normalizeCoeff [coeff]
	(Math/round (* coeff (Math/pow 2 scale)))
	)

(defn peaking [G fc Q fs]
	(let [K (Math/tan (/ (* pi fc) fs))]
	(let [V00 (Math/pow 10 (/ G 20))]

	(if (< V00 1)
		(def V0 (/ 1 V00))
		(def V0 V00))

	(let [denom (+ 1 (* (/ 1 Q) K) (pow2 K))]

	(if (> G 0)
		(do
			(def B0 (/ (+ 1 (* K (/ V0 Q)) (pow2 K)) denom))
			(def B1 (/ (* 2 (+ (pow2 K) (- 1))) denom))
			(def B2 (/ (+ 1 (- (* K (/ V0 Q))) (pow2 K)) denom))
			(def A1 B1)
			(def A2 (/ (+ 1 (- (* K (/ 1 Q))) (pow2 K)) denom))
			(def A0 1)

			))

	(if (<= G 0)
		(do
			(def B0 (/ (+ 1 (* K (/ 1 Q)) (pow2 K)) denom))
			(def B1 (/ (* 2 (+ (pow2 K) (- 1))) denom))
			(def B2 (/ (+ 1 (- (* K (/ 1 Q))) (pow2 K)) denom))
			(def A1 B1)
			(def A2 (/ (+ 1 (- (* K (/ V0 Q))) (pow2 K)) denom))
			(def A0 1)
			))
	))))

(defn shelving [G fc fs Q type]

	(let [K (Math/tan (/ (* pi fc) fs))]
	(let [V00 (Math/pow 10 (/ G 20))]
	(let [root2 (/ 1 Q)]

	(if (< V00 1)
		(def V0 (/ 1 V00))
		(def V0 V00))

	;BASE BOOST
	(if (and (> G 0) (== 0 (compare type "baseshelf")))
		(let [denom (+ 1 (* root2 K) (pow2 K)) ]
			;(println "denom -" denom)
		(def B0 (/ (+ 1 (* root2 (sqrt V0) K) (* V0 (pow2 K))) denom))
		(def B1 (/ (- (* 2 V0 (pow2 K)) 2) denom))
		(def B2 (/ (+ 1 (* (- root2) (sqrt V0) K) (* V0 (pow2 K))) denom))
		(def A1 (/ (- (* 2 (pow2 K)) 2) denom))
		(def A2 (/ (+ 1 (- (* root2 K)) (pow2 K)) denom))
		(def A0 1)
		))

	;BASE CUT
	(if (and (< G 0) (== 0 (compare type "baseshelf")))
		(let [denom (+ 1 (* root2 K (sqrt V0)) (* V0 (pow2 K))) ]
			;(println "denom -" denom)
		(def B0 (/ (+ 1 (* root2 K) (pow2 K)) denom))
		(def B1 (/ (- (* 2 (pow2 K)) 2) denom))
		(def B2 (/ (+ 1 (- (* root2 K)) (pow2 K)) denom))
		(def A1 (/ (- (* 2 V0 (pow2 K)) 2) denom))
		(def A2 (/ (+ 1 (* (- root2) (sqrt V0) K) (* V0 (pow2 K))) denom))
		(def A0 1)
		))

	;TREBLE BOOST
	(if (and (> G 0) (== 0 (compare type "trebleshelf")))
		(let [denom (+ 1 (* root2 K) (pow2 K)) ]
			;(println "denom -" denom)
		(def B0 (/ (+ V0 (* root2 K (sqrt V0)) (pow2 K)) denom))
		(def B1 (/ (- (* 2 (pow2 K)) (* 2 V0)) denom))
		(def B2 (/ (+ V0 (* (- root2) (sqrt V0) K) (pow2 K)) denom))
		(def A1 (/ (- (* 2 (pow2 K)) 2) denom))
		(def A2 (/ (+ 1 (- (* root2 K)) (pow2 K)) denom))
		(def A0 1)
		))

	;TREBLE CUT
	(if (and (< G 0) (== 0 (compare type "trebleshelf")))
		(let [denom1 (+ V0 (* root2 (sqrt V0) K) (pow2 K)) ]
			;(println "denom1 -" denom1)
		(let [denom2 (+ 1 (* (/ root2 (sqrt V0)) K) (/(pow2 K) V0)) ]
			;(println "denom2 -" denom2)
		(def B0 (/ (+ 1 (* root2 K) (pow2 K)) denom1))
		(def B1 (/ (- (* 2 (pow2 K)) 2) denom1))
		(def B2 (/ (+ 1 (- (* root2 K)) (pow2 K)) denom1))
		(def A1 (/ (- (* 2 (/ (pow2 K) V0)) 2) denom2))
		(def A2 (/ (+ 1 (* (/ (- root2) (sqrt V0)) K) (/ (pow2 K) V0)) denom2))
		(def A0 1)
		)))

	))))

(defn base_shelve [g]

	(println "***BASE SHELVE***")
	(let [fc 300]
	(let [G -10]
	(let [Q (/ 1 (sqrt 2))]
	(let [type "baseshelf"]

	(shelving g fc fsample Q type)
	;(println A0 A1 A2 B0 B1 B2)
	;(long-array [A0 A1 A2 B0 B1 B2])

	(long-array (map normalizeCoeff [A0 A1 A2 B0 B1 B2]))

	)))))

(defn mid_peak [g]

	(println "***MID PEAK***")
	(let [fc 5000]
	(let [G 10]
	(let [Q (/ 1 (sqrt 0.1))]

	(peaking g fc Q fsample)
	;(println A0 A1 A2 B0 B1 B2)
	;(long-array [A0 A1 A2 B0 B1 B2])

	(long-array (map normalizeCoeff [A0 A1 A2 B0 B1 B2]))

	))))

(defn treble_shelve [g]

	(println "***TREBLE SHELVE***")
	(let [fc 10000]
	(let [G -10]
	(let [Q (/ 1 (sqrt 1.3))]
	(let [type "trebleshelf"]

	(shelving g fc fsample Q type)
	;(println A0 A1 A2 B0 B1 B2)

	(long-array (map normalizeCoeff [A0 A1 A2 B0 B1 B2]))

	)))))

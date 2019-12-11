(require '[clojure.java.shell :as sh]
          '[clojure.java.io :as io])

(def directions {:north 0
                :east 1
                :south 2
                :west 3})

(def area {{:x 0 :y 0}  0})

(defn amount-of-painted-squares [] (
    count area
))

(defn get-color [coordinate](
    get area coordinate 0
))

(def robot {
    :position {:x 0, :y 0}
    :facing (directions :north)
})

(defn x [] (get-in robot [:position :x]))
(defn y [] (get-in robot [:position :y]))

(defn forward [robot] (
    case (robot :facing)
        0 {:x (x) :y (+ (y)y 1)}
        3 {:x (- (x) 1) :y (y)}
        2 {:x (x) :y (- (y) 1)}
        1 {:x (+ (x) 1) :y (y)}
))

(defn turn-left [] (
    case (robot :facing)
        0 (directions :west)
        3 (directions :south)
        2 (directions :east)
        1 (directions :north)
))

(defn turn-right [] (
    case (robot :facing)
        0 (directions :east)
        3 (directions :north)
        2 (directions :west)
        1 (directions :south)
))

(defn move [rotate] (
    def robot (
        let [rotated-robot (assoc robot :facing (rotate))] (
            assoc rotated-robot :position (
                forward rotated-robot
            )
        )
    )
))

(defn move-left [] (
    move turn-left
))

(defn move-right [] (
    move turn-right
))

(defn apply-movement [input] (
    if (= input "0") (
        move-left
    ) (
        move-right
    )
))

(defn paint [coordinate, color] (
    def area (
        assoc area coordinate color
    )
))

(defn write-color [writer] (
    (.write writer (get-color (robot :position)))
    (.newLine writer)
))

(def cmd ["./intcode"])
(def proc (.exec (Runtime/getRuntime) (into-array cmd)))
(def output (io/reader (.getInputStream proc)))
(def input (io/writer (.getOutputStream proc)))
(write-color input)
(def firstOutput true)

(let [cmd ["./intcode"]
      proc (.exec (Runtime/getRuntime) (into-array cmd))]
    (with-open [output (io/reader (.getInputStream proc))
                input (io/writer (.getOutputStream proc))]
        (doseq [line (line-seq rdr)]
          (
              if (true? firstOutput) (
                  paint (robot :position) line
              ) (
                  (apply-movement line)
                  (println robot)
                  (write-color input)
              )
          )
        )
    )
)
(println robot)
(println (amount-of-painted-squares))

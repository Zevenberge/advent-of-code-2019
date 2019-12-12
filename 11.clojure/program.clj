(require '[clojure.java.shell :as sh]
          '[clojure.java.io :as io])

(def directions {:north 0
                :east 1
                :south 2
                :west 3})

(def area {{:x 0 :y 0}  "1"})

(defn amount-of-painted-squares [] (
    count area
))

(defn get-color [coordinate](
    get area coordinate "0"
))

(def robot {
    :position {:x 0, :y 0}
    :facing (directions :north)
})

(defn x [] (get-in robot [:position :x]))
(defn y [] (get-in robot [:position :y]))

(defn forward [robot] (
    case (robot :facing)
        0 {:x (x) :y (+ (y) 1)}
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

(defn write-color [writer] (do
    (.write writer (get-color (robot :position)))
    (.newLine writer)
    (.flush writer)
))

(let [cmd ["./intcode"]
      proc (.exec (Runtime/getRuntime) (into-array cmd))
      write-color write-color
      firstOutput true]
    (with-open [output (io/reader (.getInputStream proc))
                input (io/writer (.getOutputStream proc))]
        (while (.isAlive proc) (do
            (write-color input)
            (let [line (.readLine output)] (do
                (paint (robot :position) line)
            ))
            (let [line (.readLine output)] (do
                (apply-movement line)
            ))
        ))
    )
)


(def xs (map :x (keys area)))
(def ys (map :y (keys area)))

(def left (apply min xs))
(def right (apply max xs))
(def top (apply max ys))
(def bottom (apply min ys))

(defn print-color [coordinate] (
    if (= "1" (get-color coordinate)) (
            print "#"
    ) (
            print "."
    )
))

(defn print-row [y] (do
    (loop [x left]
        (when (<= x right)
            (print-color {:x x :y y})
            (recur (+ x 1))
        )   
    )
    (println "")
))

(loop [y bottom] (
    when (<= y top)
    (print-row y)
    (recur (+ y 1))
))



import java.io.File
import java.io.BufferedReader
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.max

data class Astroid(val x: Int, val y: Int)

fun between(min: Int, value: Int, max: Int) : Boolean {
    if(max < min) return between(max, value, min) //>
    return min < value && value < max //>>
}

fun isOnOtherSide(delta: Int, deltaObstacle: Int) : Boolean {
    return delta * deltaObstacle < 0 //>
}

fun isOneAlignedButTheOtherIsNot(delta: Int, deltaObstacle: Int) : Boolean {
    if(delta == 0) return deltaObstacle != 0
    return deltaObstacle == 0
}

fun gcd(x: Int, y: Int) : Int {
    var a = abs(x);
    var b = abs(y);
    while(b > 0)
    {
        val temp = b
        b = a % b
        a = temp
    }
    return a
}

fun isInLineOfSight(from: Astroid, to: Astroid, obstacle: Astroid) : Boolean {
    if(from.x == to.x) return from.x == obstacle.x && between(from.y, obstacle.y, to.y)
    if(from.y == to.y) return from.y == obstacle.y && between(from.x, obstacle.x, to.x)
    if(!between(from.x, obstacle.x, to.x)) return false
    if(!between(from.y, obstacle.y, to.y)) return false
    var left = from.x
    val right = to.x
    var top = from.y
    val bottom = to.y
    val diffX = obstacle.x - left
    val diffY = obstacle.y - top
    val gcd = gcd(diffX, diffY)
    val stepX = diffX / gcd
    val stepY = diffY / gcd
    do {
        left += stepX
        top += stepY
        if(left == right && top == bottom) return true
    } while(between(from.x, left, to.x))
    return false 
}

fun canDetect(from: Astroid, to: Astroid, others: List<Astroid>) : Boolean {
    if (from.equals(to)) {
        return false
    }
    for (other in others) {
        if (other.equals(from)) continue
        if (other.equals(to)) continue
        if (isInLineOfSight(from, to, other)) {
            return false
        }
    }
    return true
}

fun countDetectableAstroids(from: Astroid, others: List<Astroid>) : Int {
    val detectableAstroids = others.filter { canDetect(from, it, others) }
    val count =  detectableAstroids.count()
    return count
}

fun maxDetectableAstroids(astroids: List<Astroid>): Int {
    val max = astroids.map {countDetectableAstroids(it, astroids)} .max()
    if (max != null) return max
    return 0
}

fun createAstroids(input: List<String>) : List<Astroid> {
    var astroids = mutableListOf<Astroid>()
    for ((y, line) in input.withIndex()) {
        for ((x, astroid) in line.withIndex()) {
            if(astroid == '#') {
                astroids.add(Astroid(x,y))
            }
        }
    }
    return astroids
}

fun main(args: Array<String>) {
    val bufferedReader = File("input.txt").bufferedReader()
	val lineList = mutableListOf<String>()
    bufferedReader.useLines { lines -> lines.forEach { lineList.add(it) } }
    val astroids = createAstroids(lineList)
    val max = maxDetectableAstroids(astroids)
    println(max)
}
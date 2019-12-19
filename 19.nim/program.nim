import osproc, streams, strutils, tables


proc spawnRobot() : Process =
    return startProcess("./intcode", ".")

proc giveCommand(process: Process, input: int) =
    var inputStream = process.inputStream()
    inputStream.writeLine(input)
    inputStream.flush()

proc readOuput(process: Process) : int =
    var output = process.outputStream()
    var text = output.readLine()
    result = text.parseInt()

type
    Square = tuple
        x: int
        y: int
    Map = Table[Square, int]

proc distance(square: Square) : int =
    return square.x * square.x + square.y * square.y

proc beamValue(square: Square) : bool =
    var robot = spawnRobot()
    robot.giveCommand(square.x)
    robot.giveCommand(square.y)
    let output = robot.readOuput()
    robot.close()
    return output == 1

proc correctBottomAngle(angle: float, y : int) : float =
    var x = (angle * y.toFloat).toInt
    var foundX = max(x * 2, 10)
    var notFoundX = 0
    while true:
        let beam = beamValue((x: x, y: y))
        if beam:
            foundX = x
            x = x - 1
        else:
            notFoundX = x
            x = x + 1
        if notFoundX + 1 == foundX:
            return x.toFloat / y.toFloat

proc findInitialBottomAngle() : float =
    return correctBottomAngle(0, 10)

proc findBottomAngle() : float =
    var angle = findInitialBottomAngle()
    var y = 20
    while y < 10_000:
        angle = correctBottomAngle(angle, y)
        y = y * 2
    result = angle

proc correctTopAngle(angle: float, x : int) : float =
    var y = (angle * x.toFloat).toInt - 4
    var foundY = max(y * 2, 20)
    var notFoundY = 0
    while true:
        let beam = beamValue((x: x, y: y))
        if beam:
            foundY = y
            y = y - 1
        else:
            notFoundY = y
            y = y + 1
        if notFoundY + 1 == foundY:
            return y.toFloat / x.toFloat

proc findInitialTopAngle() : float =
    #return correctTopAngle(0, 10)
    let x = 10
    for y in 0 .. 15:
        let beam = beamValue((x: x, y:y));
        if beam:
            return y.toFloat / x.toFloat
    result = 0;

proc findTopAngle() : float =
    var angle = findInitialTopAngle()
    var x = 20
    while x < 10_000:
        angle = correctTopAngle(angle, x)
        x = x * 2
    result = angle

proc moveAroundABit(coordA : Square) : Square =
    let coordB : Square = (x: coordA.x + 99, y: coordA.y - 99)
    var closestPoint : Square = (x: 99_999, y: 99_999)
    for shiftX in -10 .. 10:
        for shiftY in -10 .. 10:
            let correctedA : Square = (x: coordA.x + shiftX, y: coordA.y + shiftY)
            let correctedB : Square = (x: coordB.x + shiftX, y: coordB.y + shiftY)
            if beamValue(correctedA) and beamValue(correctedB):
                let correctedPoint : Square = (x: correctedA.x, y: correctedB.y)
                stdout.writeLine(correctedPoint)
                if correctedPoint.distance < closestPoint.distance:
                    closestPoint = correctedPoint
    return closestPoint

let a = findBottomAngle()
let b = findTopAngle()
let xb = 100 * (1 + a) / (1 - a*b)
let yb = xb * b
let xa = xb - 100
let ya = xa / a

let coordA : Square = (x: xa.toInt, y: ya.toInt)
let coordB : Square = (x: xb.toInt, y: yb.toInt)

stdout.writeLine(beamValue(coordA))
stdout.writeLine(beamValue(coordB))

stdout.writeLine("A: ", coordA)
stdout.writeLine("B: ", coordB)

let finalPoint = moveAroundABit(coordA)
stdout.writeLine(finalPoint)
stdout.writeLine(finalPoint.x * 10_000 + finalPoint.y)
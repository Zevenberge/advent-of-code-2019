import osproc, streams, strutils


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
        value: char

type
    Chart = array[0 .. 30, array[0 .. 39, Square]]

type
    Direction = enum
      north, east, south, west

type
    Robot = tuple
        x: int
        y: int
        d: Direction

proc turnLeft(robot: Robot) : Robot =
    if robot.d == north:
        result = (x: robot.x, y: robot.y, d: west)
    else: 
        if robot.d == west:
            result = (x: robot.x, y: robot.y, d: south)
        else: 
            if robot.d == south:
                result = (x: robot.x, y: robot.y, d: east)
            else:
                result = (x: robot.x, y: robot.y, d: north)

proc turnRight(robot: Robot) : Robot =
    if robot.d == north:
        result = (x: robot.x, y: robot.y, d: east)
    else: 
        if robot.d == west:
            result = (x: robot.x, y: robot.y, d: north)
        else: 
            if robot.d == south:
                result = (x: robot.x, y: robot.y, d: west)
            else:
                result = (x: robot.x, y: robot.y, d: south)

proc move(robot: Robot, amount: int) : Robot =
    if robot.d == north:
        result = (x: robot.x, y: robot.y - amount, d:robot.d)
    else: 
        if robot.d == west:
            result = (x: robot.x - amount, y: robot.y, d: robot.d)
        else: 
            if robot.d == south:
                result = (x: robot.x, y: robot.y + amount, d: robot.d)
            else: # east
                result = (x: robot.x + amount, y: robot.y, d: robot.d)


proc readChart(process: Process) : Chart =
    var i = 0
    var j = 0
    var chart : Chart
    var previousOutput = ' '
    while true:
        var output = char(process.readOuput())
        if output == char(10):
            if previousOutput == output:
                break
            stdout.write(j)
            j = j + 1
            i = 0
        else:
            var square : Square
            square = (x: i, y: j, value: output)
            chart[j][i] = square
            i = i + 1
        stdout.write(output)
        previousOutput = output
    result = chart

proc isCrossSection(chart: Chart, square: Square) : bool =
    for y in square.y - 1 .. square.y + 1:
        if chart[y][square.x].value != '#':
            result = false
            return
    for x in square.x - 1 .. square.x + 1:
        if chart[square.y][x].value != '#':
            result = false
            return
    result = true

proc determineAlignmentParamters(chart: Chart) : int =
    var sum = 0
    for y in 1..29:
        for x in 1 .. 38:
            if chart.isCrossSection(chart[y][x]):
                sum = sum + x * y
    result = sum

proc isOutOfBounds(robot: Robot) : bool =
    result = robot.x < 0 or robot.x > 39 or robot.y < 0 or robot.y > 30

proc shouldTurnLeft(robot: Robot, chart: Chart) : bool =
    var proxy = robot.turnLeft().move(1);
    if proxy.isOutOfBounds():
        result = false
    else:
        result = chart[proxy.y][proxy.x].value == '#'

proc shouldTurnRight(robot: Robot, chart: Chart) : bool =
    var proxy = robot.turnRight().move(1);
    if proxy.isOutOfBounds():
        result = false
    else:
        result = chart[proxy.y][proxy.x].value == '#'

proc determineMovement(robot: Robot, chart: Chart) : int =
    var proxy = robot
    var steps = -1
    while chart[proxy.y][proxy.x].value == '#' or chart[proxy.y][proxy.x].value == '^':
        steps = steps + 1
        proxy = proxy.move(1)
        if proxy.isOutOfBounds():
            break
    result = steps

proc findRoute(chart: Chart) : seq[string] =
    var route: seq[string]
    route = @[]
    var robot: Robot
    robot = (x:4, y: 0, d: north)
    var done = false
    while done == false:
        if robot.shouldTurnLeft(chart):
            route.add("L")
            stdout.write("L")
            robot = robot.turnLeft()
        else:
            if robot.shouldTurnRight(chart):
                route.add("R")
                stdout.write("R")
                robot = robot.turnRight()
            else:
                done = true
                break
        var movement = robot.determineMovement(chart)
        stdout.write(movement)
        robot = robot.move(movement)
        route.add(intToStr(movement))
    stdout.writeLine(' ')
    result = route



proc print(chart: Chart) =
    for y in 0 .. 30:
        stdout.writeLine(' ')
        for x in 0 .. 38:
            stdout.write(chart[y][x].value)
        

var robot = spawnRobot()
var chart = robot.readChart()
chart.print()
var route = chart.findRoute()

var sum = chart.determineAlignmentParamters();
stdout.writeLine(sum)
#robot.giveCommand(1)
#stdout.writeLine(robot.readOuput())
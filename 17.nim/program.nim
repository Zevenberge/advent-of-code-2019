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

type
    Move = enum
        straight, left, right

type
    Coord = tuple
        x: int
        y: int
    
proc findIntersections(chart: Chart) : seq[Coord] =
    result = @[]
    for y in 1..29:
        for x in 1 .. 38:
            if chart.isCrossSection(chart[y][x]):
                result.add((x: x, y: y))

proc isOutOfBounds(robot: Robot) : bool =
    result = robot.x < 0 or robot.x > 39 or robot.y < 0 or robot.y > 30

type
    Intersection = tuple
        x: int
        y: int
        move: Move

proc shouldTurnLeft(robot: Robot, chart: Chart, intersections : seq[Intersection]) : bool =
    for intersection in intersections:
        if intersection.x == robot.x and intersection.y == robot.y:
            return intersection.move == left
    var proxy = robot.turnLeft().move(1);
    if proxy.isOutOfBounds():
        result = false
        return
    result = chart[proxy.y][proxy.x].value == '#'

proc shouldTurnRight(robot: Robot, chart: Chart, intersections : seq[Intersection]) : bool =
    for intersection in intersections:
        if intersection.x == robot.x and intersection.y == robot.y:
            return intersection.move == right
    var proxy = robot.turnRight().move(1);
    if proxy.isOutOfBounds():
        result = false
    else:
        result = chart[proxy.y][proxy.x].value == '#'

type
    Forward = tuple
        amount: int
        passedIntersections: seq[Intersection]

proc determineMovement(robot: Robot, chart: Chart, intersections: seq[Intersection]) : Forward =
    var passedIntersections : seq[Intersection]
    passedIntersections = @[]
    var proxy = robot
    var steps = -1
    while chart[proxy.y][proxy.x].value == '#' or chart[proxy.y][proxy.x].value == '^':
        steps = steps + 1
        proxy = proxy.move(1)
        if proxy.isOutOfBounds():
            break
        var stoppedAtIntersection = false
        for intersection in intersections:
            if intersection.x == proxy.x and intersection.y == proxy.y:
                passedIntersections.add(intersection)
                if not (intersection.move == straight):
                    stoppedAtIntersection = true
        if stoppedAtIntersection:
            steps = steps + 1 # Off by one because we still need to move towards the intersection
            break
    result = (amount: steps, passedIntersections: passedIntersections)

type
    Route = tuple
        steps: seq[string]
        valid: bool

proc toIntersections(coords: seq[Coord]) : seq[Intersection] =
    result = @[]
    for coord in coords:
        result.add((x: coord.x, y: coord.y, move: straight))

proc isStuckInALoopAt(intersections: seq[Intersection], place: Intersection) : bool =
    var count = 0
    for i in intersections:
        if i.x == place.x and i.y == place.y:
            count = count + 1
    result = count > 2

proc findRoute(chart: Chart, intersections: seq[Intersection]) : Route =
    let endPoint : Coord = (x: 24, y: 4)
    var route: seq[string]
    route = @[]
    var passedIntersections : seq[Intersection]
    passedIntersections = @[]
    var robot: Robot
    robot = (x:4, y: 0, d: north)
    var done = false
    while done == false:
        if robot.shouldTurnLeft(chart, intersections):
            route.add("L")
            robot = robot.turnLeft()
        else:
            if robot.shouldTurnRight(chart, intersections):
                route.add("R")
                robot = robot.turnRight()
            else:
                done = true
                break
        var movement = robot.determineMovement(chart, intersections)
        for intersection in movement.passedIntersections:
            passedIntersections.add(intersection)
            if passedIntersections.isStuckInALoopAt(intersection):
                done = true
        robot = robot.move(movement.amount)
        route.add(intToStr(movement.amount))
    var valid = robot.x == endPoint.x and robot.y == endPoint.y
    result = (steps: route, valid: valid)

proc containtsAt(route: seq[string], command: seq[string], index: int) : bool =
    if index + command.len > route.len:
        return false
    var i = index
    for step in command:
        if not (route[i] == step):
            result = false
            return
        i = i + 1
    return true

proc replace(route: seq[string], command: seq[string]) : seq[string] =
    result = @[]
    var i = 0
    while i < route.len:
        if route.containtsAt(command, i):
            result.add("NOPE")
            i = i + command.len
        else:
            result.add(route[i])
            i = i + 1

proc first(route: seq[string], amount: int) : seq[string] =
    result = @[]
    var offset = 0
    for step in route:
        if step == "NOPE":
            offset = offset + 1
        else:
            break
    for i in 0 .. amount - 1:
        if i + offset > (route.len - 1):
            break
        result.add(route[i + offset])

proc isValidLength(command: seq[string]) : bool =
    var length = command.len - 1 # comma's
    for step in command:
        length = length + step.len
    result = length < 21

proc doesNotContainTerminator(command: seq[string]) : bool =
    result = true
    for step in command:
        if step == "NOPE":
            result = false

proc isValid(command: seq[string]) : bool =
    result = command.isValidLength() and command.doesNotContainTerminator()

proc isEmpty(route: seq[string]) : bool =
    result = true
    for step in route:
        if not (step == "NOPE"):
            result = false

type
    Program = tuple
        functions: seq[seq[string]]
        success: bool

proc findProgramImpl(route: seq[string], depth: int) : Program =
    var commandSize = 10
    if route.len < commandSize:
        commandSize = route.len
    while commandSize > 0:
        var command = route.first(commandSize)
        if command.isValid():
            var reducedRoute = route.replace(command)
            if depth == 0:
                if reducedRoute.isEmpty():
                    result = (functions: @[command], success: true)
                    return
            else:
                var program = findProgramImpl(reducedRoute, depth - 1)
                if program.success:
                    result = (functions: @[command], success: true)
                    for function in program.functions:
                        result.functions.add(function)
                    return
        commandSize = commandSize - 1
    return (functions: @[], success: false)


proc findProgram(route: seq[string]) : Program =
    result = findProgramImpl(route, 2)

proc findRoutesWithIntersections(chart: Chart, intersections : var seq[Intersection], i : int) : seq[Route] =
    result = @[]
    if i == intersections.len:
        var route = chart.findRoute(intersections)
        if route.valid:
            result.add(route)
        return
    for move in [straight, left, right]:
        intersections[i].move = move
        var routes = findRoutesWithIntersections(chart, intersections, i + 1)
        for route in routes:
            result.add(route)

type
    SolvedProgram = tuple
        program: Program
        route: Route

proc findSolvableRoute(chart: Chart) : SolvedProgram =
    var intersections = chart.findIntersections().toIntersections()
    var routes = chart.findRoutesWithIntersections(intersections, 0)
    stdout.writeLine("Found ", routes.len)
    for route in routes:
        var program = route.steps.findProgram()
        if program.success:
            result = (program: program, route: route)
            return
    result = (program: (functions: @[], success: false), route: (steps: @[], valid: false))

proc print(chart: Chart) =
    for y in 0 .. 30:
        stdout.writeLine(' ')
        for x in 0 .. 38:
            stdout.write(chart[y][x].value)
    stdout.writeLine(' ')

type 
    Message = tuple
        functions : seq[string]
        a : seq[string]
        b: seq[string]
        c: seq[string]

proc findMessage(program : SolvedProgram) : Message =
    var a = program.program.functions[0]
    var b = program.program.functions[1]
    var c = program.program.functions[2]
    var calls : seq[string] = @[]
    var i = 0
    var route = program.route.steps
    while i < route.len:
        if route.containtsAt(a, i):
            calls.add("A")
            i += a.len
            continue
        if route.containtsAt(b, i):
            calls.add("B")
            i += b.len
            continue
        if route.containtsAt(c, i):
            calls.add("C")
            i += c.len
            continue
        stdout.writeLine("HELP HELP")
        break

    return (functions: calls, a: a, b: b, c: c)

proc sendString(robot: Process, text : string) =
    for c in text:
        robot.giveCommand(int(c))

proc sendLine(robot: Process, line : seq[string]) =
    robot.sendString(line[0])
    for i in 1 .. line.len - 1:
        robot.sendString(",")
        robot.sendString(line[i])
    robot.giveCommand(10)

proc send(robot: Process, message : Message) =
    robot.sendLine(message.functions)
    robot.sendLine(message.a)
    robot.sendLine(message.b)
    robot.sendLine(message.c)

var robot = spawnRobot()
var chart = robot.readChart()
chart.print()

var program = chart.findSolvableRoute()
for step in program.route.steps:
    stdout.write("\"", step, "\",")
stdout.writeLine(' ')
for function in program.program.functions:
    for step in function:
        stdout.write(step)
    stdout.writeLine(' ')
var message = program.findMessage()
for call in message.functions:
    stdout.write(call)
robot.send(message)
robot.sendLine(@["n"])
while true:
    # it explodes, but hey. We got the answer
    robot.readChart().print()

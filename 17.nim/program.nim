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
    var stop = false
    for y in square.y - 1 .. square.y + 1:
        if chart[y][square.x].value != '#':
            result = false
            stop = true
    for x in square.x - 1 .. square.x + 1:
        if chart[square.y][x].value != '#':
            result = false
            stop = true
    if stop == false:
        result = true

proc determineAlignmentParamters(chart: Chart) : int =
    var sum = 0
    for y in 1..29:
        for x in 1 .. 38:
            if chart.isCrossSection(chart[y][x]):
                sum = sum + x * y
    result = sum

proc print(chart: Chart) =
    for y in 0 .. 30:
        stdout.writeLine(' ')
        for x in 0 .. 38:
            stdout.write(chart[y][x].value)
        

var robot = spawnRobot()
var chart = robot.readChart()
chart.print()

var chart2 : Chart

var sum = chart.determineAlignmentParamters();
stdout.writeLine(sum)
#robot.giveCommand(1)
#stdout.writeLine(robot.readOuput())
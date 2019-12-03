def parseMovement(movement):
    amplitude = int(movement[1:])
    if movement[0] == 'R':
        return [amplitude, 0]
    elif movement[0] == 'U':
        return [0, amplitude]
    elif movement[0] == 'L':
        return [-amplitude, 0]
    elif movement[0] == 'D':
        return [0, -amplitude]
    else:
        print(movement)
        pass

def piecewiseSum(first, second):
    return [x + y for x, y in zip(first, second)]

class LinePiece:
    def __init__(self, begin, movement, previous):
        self.previous = previous
        self.begin = begin
        self.vector = parseMovement(movement)
        self.movesHorizontally = self.vector[0] != 0
        self.movesVectically = self.vector[1] != 0
        self.end = piecewiseSum(begin, self.vector)

    def intersects(self, other):
        if self.movesHorizontally and other.movesHorizontally:
            return False
        if self.movesVectically and other.movesVectically:
            return False
        if self.movesHorizontally:
            return self.findHorizontalIntersection(other)
        return self.findVerticalIntersection(other)

    def crossesVertically(self, other):
        minimal = min(self.begin[0], self.end[0])
        maximal = max(self.begin[0], self.end[0])
        return minimal < other.begin[0] < maximal

    def crossesHorizontally(self, other):
        minimal = min(self.begin[1], self.end[1])
        maximal = max(self.begin[1], self.end[1])
        return minimal < other.begin[1] < maximal

    def findHorizontalIntersection(self, other):
        if self.crossesVertically(other) and other.crossesHorizontally(self):
            intersection = [other.begin[0], self.begin[1]]
            return self.intersectionWithDistance(other, intersection)
        return None

    def findVerticalIntersection(self, other):
        if self.crossesHorizontally(other) and other.crossesVertically(self):
            intersection = [self.begin[0], other.begin[1]]
            return self.intersectionWithDistance(other, intersection)
        return None

    def intersectionWithDistance(self, other, intersection):
        if intersection[0] == 0 and intersection[1] == 0:
            return None
        myDistance = self.calculateDistanceWalkedUntilIntersection(intersection)
        theirDistance = other.calculateDistanceWalkedUntilIntersection(intersection)
        return [intersection[0], intersection[1], myDistance + theirDistance]

    def calculateDistanceWalkedUntilIntersection(self, intersection):
        extraDistance = abs(intersection[0] - self.begin[0] + intersection[1] - self.begin[1])
        if self.previous is None:
            return extraDistance
        return extraDistance + self.previous.distanceWalked()

    def distanceWalked(self):
        distanceOfThis = abs(self.vector[0] + self.vector[1])
        if self.previous is None:
            return distanceOfThis
        return distanceOfThis + self.previous.distanceWalked() 

class Line:
    def __init__(self, steps):
        self.pieces = []
        begin = [0, 0]
        previous = None
        for step in steps.split(','):
            piece = LinePiece(begin, step, previous)
            begin = piece.end
            self.pieces.append(piece)
            previous = piece
    
    def findIntersections(self, other):
        intersections = []
        for myPiece in self.pieces:
            for theirPiece in other.pieces:
                possibleIntersection = myPiece.intersects(theirPiece)
                if possibleIntersection != False and possibleIntersection is not None:
                    intersections.append(possibleIntersection)
        return intersections

    def findLowestManhattanIntersection(self, other):
        intersections = self.findIntersections(other)
        minimalIntersection = 9_999_999
        for intersection  in intersections:
            manhattanNorm = abs(intersection[0]) + abs(intersection[1])
            if manhattanNorm < minimalIntersection:
                minimalIntersection = manhattanNorm
        return minimalIntersection

    def findIntersectionWithShortestWalk(self, other):
        intersections = self.findIntersections(other)
        shortestDistance = 9_999_999
        for intersection  in intersections:
            distanceWalked = intersection[2]
            if distanceWalked < shortestDistance:
                shortestDistance = distanceWalked
        return shortestDistance

lineA = Line("R8,U5,L5,D3")
lineB = Line("U7,R6,D4,L4")
print(lineA.findLowestManhattanIntersection(lineB))
print(lineA.findIntersectionWithShortestWalk(lineB))
lineA = Line("R75,D30,R83,U83,L12,D49,R71,U7,L72")
lineB = Line("U62,R66,U55,R34,D71,R55,D58,R83")
print(lineA.findLowestManhattanIntersection(lineB))
print(lineA.findIntersectionWithShortestWalk(lineB))
lineA = Line("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
lineB = Line("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
print(lineA.findLowestManhattanIntersection(lineB))
print(lineA.findIntersectionWithShortestWalk(lineB))
with open("input.txt") as f:
    content = f.readlines()
content = [x.strip() for x in content]
lineA = Line(content[0])
lineB = Line(content[1])
print(lineA.findLowestManhattanIntersection(lineB))
print(lineA.findIntersectionWithShortestWalk(lineB))
import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
//import etc.linux.memoryerror;

struct Coord
{
    int x;
    int y;

    Coord move(const Coord movement) const
    {
        return Coord(x + movement.x, y + movement.y);
    }

    bool isOpposite(const Coord other) const
    {
        return x == -other.x && y == -other.y;
    }

    int quadrant() const
    {
        if(x < boundary && y < boundary) return 1;
        if(x < boundary && y > boundary) return 2;
        if(x > boundary && y < boundary) return 3;
        if(x > boundary && y > boundary) return 4;
        return 0;
    }

    bool isSameQuadrant(const Coord other) const
    {
        return this.quadrant == other.quadrant;
    }

    Coord startOfThisQuadrant() const
    {
        switch(quadrant)
        {
            case 1:
                return Coord(boundary -1, boundary -1);
            case 2:
                return Coord(boundary - 1, boundary+1);
            case 3:
                return Coord(boundary+1, boundary-1);
            case 4:
                return Coord(boundary+1, boundary+1);
            default:
                assert(false);
        }
    }

    bool isCenter() const
    {
        return x == boundary && y == boundary;
    }
}

enum Value { None, Wall, Key, Door };

abstract class Field
{
    bool canPass() { return true; }
}

class Wall : Field
{
    override bool canPass() { return false; }
}

class Path : Field
{

}

class Key : Field
{
    this(char name, Coord location)
    {
        this.name = name;
        this.location = location;
    }

    const char name;
    const Coord location;
    Door[] blockedBy;
    bool[Key] blockedByKeys;
    size_t[Key] distanceToKeys;
    size_t distanceToCenter;

    private void flatten(Key other)
    {
        foreach(door; other.blockedBy)
        {
            blockedByKeys[door.required] = true;
            flatten(door.required);
        }
    }

    void flatten()
    {
        flatten(this);
    }

    override string toString()
    {
        return name ~ " " ~ location.to!string;
    }

    override size_t toHash() const @safe pure nothrow
    {
        return cast(size_t)name;
    }

    bool isBlockedBy(Key other)
    {
        if(auto blockedBy = other in blockedByKeys)
        {
            return *blockedBy;
        }
        return false;
    }

    bool isReachable(Key[] gatheredKeys)
    {
        foreach(kvp; blockedByKeys.byKeyValue)
        {
            if(!gatheredKeys.any!(key => key is kvp.key))
            {
                if(kvp.value)
                {
                    return false;
                }
            }
        }
        return true;
    }
}

class Door : Field
{
    this(char name)
    {
        import std.ascii : toLower;
        this.name = name.toLower();
    }

    const char name;
    Key required;
}

Field[][] maze;
Coord you;

void parseFile()
{
    auto lines = File("maze.txt").byLineCopy.array;
    auto height = lines.length.to!int;
    auto width = lines[0].length.to!int;
    foreach(i; 0.. width)
    {
        maze ~= new Field[height];
    }
    foreach(int x; 0 .. width)
    {
        foreach(int y; 0 .. height)
        {
            auto element = lines[y][x];
            switch(element)
            {
                case '#':
                    maze[x][y] = new Wall;
                    break;
                case '.':
                    maze[x][y] = new Path;
                    break;
                case '@':
                    maze[x][y] = new Path;
                    you = Coord(x, y);
                    break;
                default:
                    if(element.isLowerCase)
                        maze[x][y] = new Key(element, Coord(x, y));
                    else
                        maze[x][y] = new Door(element);
                    break;
            }
        }
    }
}

auto allFields()
{
    return maze.joiner;
}

auto allKeys()
{
    return allFields.filter!(f => cast(Key)f).map!(f => cast(Key)f);
}

auto allDoors()
{
    return allFields.filter!(f => cast(Door)f).map!(f => cast(Door)f);
}

void connectKeysToDoors()
{
    foreach(Door door; allDoors)
    {
        auto key = allKeys
            .filter!(k => k.name == door.name)
            .front;
        door.required = key;
    }
}

void findBlockingDoors()
{
    foreach(Key key; allKeys)
    {
        auto path = findPath(you, key.location);
        key.distanceToCenter = path.length;
        foreach(coord; path)
        {
            auto field = maze[coord.x][coord.y];
            if(field is key) continue;
            auto door = cast(Door)field;
            if(door) key.blockedBy ~= door;
            auto otherKey = cast(Key)field;
            if(otherKey)
            {
                //key.keysOnPath ~= otherKey;
                key.blockedByKeys[otherKey] = true;
                //otherKey.onThePathToKeys ~= key;
            }
        }
    }
}

void flattenKeys()
{
    foreach (key; allKeys)
    {
        key.flatten;
    }
}

void determineDistances()
{
    auto keys = allKeys.array;
    foreach(i; 0 .. keys.length)
    {
        auto key = keys[i];
        foreach(j; i+1 .. keys.length)
        {
            auto otherKey = keys[j];
            auto distance = findPath(key.location, otherKey.location).length;
            key.distanceToKeys[otherKey] = distance;
            otherKey.distanceToKeys[key] = distance;
        }
    }
}

size_t gatherKeys(Key[] found, Key[] remaining)
{
    if(remaining.length == 1)
    {
        return remaining[0].distanceToKeys[found[$-1]];
    }
    //writeln("Found ", found);
    Key[] reachableKeys;
    Key[] unreachableKeys;
    foreach (Key key; remaining)
    {
        if(key.isReachable(found))
            reachableKeys ~= key;
        else
            unreachableKeys ~= key;
    }
    //writeln("Reachable ", reachableKeys);
    size_t minDistance = size_t.max/2;
    foreach(i, key; reachableKeys)
    {
        size_t distance;
        if(found.length == 0)
        {
            distance = key.distanceToCenter;
        }
        else
        {
            distance = key.distanceToKeys[found.back];
        }
        auto keysNotGrabbed = reachableKeys[0 .. i] ~ reachableKeys [i + 1 .. $];
        distance += gatherKeys(found ~ key, keysNotGrabbed ~ unreachableKeys);
        if(distance < minDistance)
        {
            minDistance = distance;
        }
        if(found.length == 0)
        {
            writeln(minDistance);
        }
    }
    return minDistance;
}

size_t gatherKeys()
{
    return gatherKeys([], allKeys.array);
}

void setUpMaze()
{
    parseFile();
    connectKeysToDoors();
    findBlockingDoors();
    flattenKeys();
}

static immutable movement = [
    Coord(-1, 0),
    Coord(0, -1),
    Coord(1, 0),
    Coord(0, 1)
];

Coord[] findPath(Coord start, Coord end, Coord previousMove)
{
    auto possibleMovements = movement.filter!(m => !m.isOpposite(previousMove)).array;
    foreach(movement; possibleMovements)
    {
        auto nextStop = start.move(movement);
        if(nextStop == end)
        {
            return [end];
        }
        if(!maze[nextStop.x][nextStop.y].canPass)
        {
            continue;
        }
        if(isActualPuzzleInput && !start.isSameQuadrant(nextStop))
        {
            continue;
        }
        auto result = findPath(nextStop, end, movement);
        if(result.length > 0)
        {
            return [nextStop] ~ result;
        }
    }
    return [];
}

Coord[] findPathAcrossQuadrants(Coord start, Coord end)
{
    Coord[] path;
    if(start.isCenter)
    {
        path = [start, start]; // Doesn't really matter what direction we go.
    }
    else
    {
        if(start.quadrant + end.quadrant == 5)
        {
            path = [start, start, start, start]; // Add 4;
        }
        else
        {
            path = [start, start]; // Add 2
        }
        path ~= findPath(start, start.startOfThisQuadrant);
    }
    path ~= findPath(end.startOfThisQuadrant, end);
    return path;
}

struct Navigation
{
    this(Coord start, Coord end)
    {
        if(start.x < end.x)
        {
            this.start = start;
            this.end = end;
            return;
        }
        if(start.x == end.x)
        {
            if(start.y < end.y)
            {
                this.start = start;
                this.end = end;
                return;
            }
        }
        this.start = end;
        this.end = start;
    }
    Coord start;
    Coord end;
}

struct WalkedPath
{
    Coord[] route;
}

WalkedPath[Navigation] knownRoutes;

Coord[] findPath(Coord start, Coord end)
{
    auto nav = Navigation(start, end);
    if(auto x = nav in knownRoutes)
    {
        return x.route;
    }
    Coord[] route;
    if(isActualPuzzleInput && !start.isSameQuadrant(end))
    {
        route = findPathAcrossQuadrants(start, end);
    }
    else
    {
        route = findPath(start, end, Coord(0,0));
    }
    knownRoutes[nav] = WalkedPath(route);
    return route;
}

void main()
{
    //static if (is(typeof(registerMemoryErrorHandler)))
    //    registerMemoryErrorHandler(); 
    setUpMaze();
    writeln("Set up maze");
    //auto keys = determineOrder();
    //keys.writeln;
    //keys.gatherKeys.writeln;
    determineDistances();
    writeln("Determined distances");
    //gatherKeys().writeln;
    findTotalDistanceBySorting().writeln;
}

bool isLowerCase(char c)
{
    import std.ascii : toLower;
    return c == c.toLower;
}

bool isActualPuzzleInput()
{
    return maze.length > 2*boundary;
}
enum boundary = 40;

/+
bool isBlockedBy(Key first, Key other)
{
    auto cache = other in first.blockedByKeys;
    if(cache)
    {
        return *cache;
    }
    else if(first.blockedBy.any!(door => door.required is other || door.required.isBlockedBy(other)))
    {
        first.blockedByKeys[other] = true;
        return true;
    }
    first.blockedByKeys[other] = false;
    return false;
}
+/

/+
size_t gatherKeys(Key[] keys)
{
    Key previousKey;
    size_t totalSteps = 0;
    //auto position = you;
    foreach(key; keys)
    {
        size_t distance;
        if(previousKey)
        {
            distance = key.distanceToKeys[previousKey];
        }
        else
        {
            distance = key.distanceToCenter;
        }
        totalSteps += distance;
        //totalSteps += path.length;
        //position = key.location;
    }
    return totalSteps;
}
+/

/+
size_t bruteForce()
{
    auto keys = allKeys.array;
    auto minStepSize = size_t.max;
    foreach(p; keys.permutations)
    {
        auto permutation = p.array;
        if(!permutation.isValidSequence) continue;
        auto stepSize = permutation.gatherKeys;
        if(stepSize < minStepSize)
            minStepSize = stepSize;
    }
    return minStepSize;
}+/

size_t totalDistance(Key[] keys)
{
    size_t sum = keys[0].distanceToCenter;
    foreach(i; 1 .. keys.length)
    {
        sum += keys[i].distanceToKeys[keys[i-1]];
    }
    return sum;
}

size_t findLocalMinimum(Key[] keys)
{
    keys = keys.determineOrder;
    size_t minimumDistance = keys.totalDistance;
    bool hasSwapped = true;
    outer: while(hasSwapped)
    {
        hasSwapped = false;
        foreach(i; 0 .. keys.length)
        {
            foreach (j; i .. keys.length)
            {
                swap(keys[i], keys[j]);
                if(!keys.isValidSequence)
                {
                    swap(keys[i], keys[j]);
                    continue;
                }
                size_t distance = keys.totalDistance;
                if(distance >= minimumDistance)
                {
                    swap(keys[i], keys[j]);
                    continue;
                }
                minimumDistance = distance;
                hasSwapped = true;
                continue outer;
            }
        }
    }
    return minimumDistance;
}

size_t findTotalDistanceBySorting()
{
    import std.random : randomShuffle;
    Key[] keys = allKeys.array;
    size_t globalMinimum = size_t.max;
    foreach(i; 0 .. 1000)
    {
        randomShuffle(keys);
        auto localMinimum = keys.findLocalMinimum;
        if(localMinimum < globalMinimum)
        {
            globalMinimum = localMinimum;
        }
    }
    return globalMinimum;
}

void swap(ref Key a, ref Key b)
{
    auto temp = a;
    a = b;
    b = temp;
}

Key[] determineOrder(Key[] keys)
{
    bool isValid = false;
    while(!isValid)
    {
        outer: foreach_reverse(i; 0 .. keys.length)
        {
            auto laterKey = keys[i];
            foreach_reverse(j; 0 .. i)
            {
                auto earlierKey = keys[j];
                if(earlierKey.isBlockedBy(laterKey))
                {
                    swap(keys[i], keys[j]);
                    continue outer;
                }
            }
        }
        isValid = keys.isValidSequence;
    }
    //keys.sort!((prev, next) => next.isBlockedBy(prev));
    return keys;
}


bool isValidSequence(Key[] keys)
{
    foreach(i; 0 .. keys.length)
    {
        foreach(j; i + 1 .. keys.length)
        {
            if(keys[i].isBlockedBy(keys[j]))
                return false;
        }
    }
    return true;
}

/+
auto notFoundKeys(Key[] found)
{
    return allKeys.filter!(k => !found.any!(f => f is k));
}

auto reachableKeys(Key[] found)
{
    return notFoundKeys(found).filter!(k => k.isReachable(found));
}
+/
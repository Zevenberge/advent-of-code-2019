import std.algorithm;
import std.array;
import std.conv;
import std.stdio;

Coord boundary;
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
        if(x < boundary.x && y < boundary.y) return 1;
        if(x < boundary.x && y > boundary.y) return 2;
        if(x > boundary.x && y < boundary.y) return 3;
        if(x > boundary.x && y > boundary.y) return 4;
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
                return Coord(boundary.x -1, boundary.y -1);
            case 2:
                return Coord(boundary.x - 1, boundary.y+1);
            case 3:
                return Coord(boundary.x + 1, boundary.y-1);
            case 4:
                return Coord(boundary.x+1, boundary.y+1);
            default:
                assert(false);
        }
    }
}

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

    bool isSameQuadrant(Key other)
    {
        return this.location.isSameQuadrant(other.location);
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

void parseFile()
{
    auto lines = File("maze.txt").byLineCopy.array;
    auto height = lines.length.to!int;
    auto width = lines[0].length.to!int;
    boundary = Coord(width/2, height/2);
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

size_t amountOfKeys;
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
        amountOfKeys++;
        auto path = findPath(key.location.startOfThisQuadrant, key.location);
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
                key.blockedByKeys[otherKey] = true;
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
        auto result = findPath(nextStop, end, movement);
        if(result.length > 0)
        {
            return [nextStop] ~ result;
        }
    }
    return [];
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
    Coord[] route = findPath(start, end, Coord(0,0));
    knownRoutes[nav] = WalkedPath(route);
    return route;
}

void main()
{
    setUpMaze();
    writeln("Set up maze");
    determineDistances();
    writeln("Determined distances");
    findTotalDistanceBySorting().writeln;
}

bool isLowerCase(char c)
{
    import std.ascii : toLower;
    return c == c.toLower;
}

size_t totalDistance(Key[] keys)
{
    size_t sum = keys[0].distanceToCenter;
    foreach(i; 1 .. keys.length)
    {
        sum += keys[i].distanceToKeys[keys[i-1]];
    }
    return sum;
}

size_t totalDistance(Key[][4] keys)
{
    size_t sum = 0;
    foreach(quadrant; keys)
    {
        sum += quadrant.totalDistance;
    }
    return sum;
}

size_t findLocalMinimum(Key[][4] keys)
{
    keys = keys.determineOrder;
    size_t minimumDistance = keys.totalDistance;
    bool hasSwapped = true;
    outer: while(hasSwapped)
    {
        hasSwapped = false;
        foreach(quadrant; keys)
        {
            foreach(i; 0 .. quadrant.length)
            {
                foreach (j; i .. quadrant.length)
                {
                    swap(quadrant[i], quadrant[j]);
                    if(!quadrant.isValidSequence || !keys.isSolvable)
                    {
                        swap(quadrant[i], quadrant[j]);
                        continue;
                    }
                    size_t distance = keys.totalDistance;
                    if(distance >= minimumDistance)
                    {
                        swap(quadrant[i], quadrant[j]);
                        continue;
                    }
                    minimumDistance = distance;
                    hasSwapped = true;
                    continue outer;
                }
            }
        }
    }
    return minimumDistance;
}

Key[][4] splitIntoQuadrants(Keys)(Keys keys)
{
    Key[][4] output;
    foreach (Key key; keys)
    {
        output[key.location.quadrant - 1] ~= key;
    }
    return output;
}

Key[][4] shuffle(Key[][4] keys)
{
    import std.random : randomShuffle;
    foreach(quadrant; keys)
    {
        randomShuffle(quadrant);
    }
    return keys;
}

size_t findTotalDistanceBySorting()
{
    auto keys = allKeys.splitIntoQuadrants;
    size_t globalMinimum = size_t.max;
    foreach(i; 0 .. 1000)
    {
        keys = shuffle(keys);
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

Key[][4] determineOrder(Key[][4] keys)
{
    return keys[].joiner.array.determineOrder.splitIntoQuadrants;
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
    return keys;
}

bool isSolvable(Key[][4] keys)
{
    size_t[4] cursor;
    Key[] receivedKeys;
    bool keyReceived = true;
    while(keyReceived)
    {
        keyReceived = false;
        foreach(q, quadrant; keys)
        {
            size_t index = cursor[q];
            if(index >= quadrant.length)
            {
                continue;
            }
            Key nextKey = quadrant[index];
            if(nextKey.isReachable(receivedKeys))
            {
                cursor[q] = index + 1;
                receivedKeys ~= nextKey;
                keyReceived = true;
            }
        }
    }
    return receivedKeys.length == amountOfKeys;
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
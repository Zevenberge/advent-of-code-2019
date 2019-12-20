import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import etc.linux.memoryerror;

Coord boundary;
struct Coord
{
    int x;
    int y;

    Coord move(const Coord movement) const
    {
        return Coord(x + movement.x, y + movement.y);
    }

    Coord opposite() const
    {
        return Coord(-x, -y);
    }

    bool isOpposite(const Coord other) const
    {
        return x == -other.x && y == -other.y;
    }

    bool isInBounds() const
    {
        return x >= 0 && y >= 0 && x < maze.length && y < maze[0].length;
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

class Void : Field
{
    override bool canPass() { return false; }
}

class Portal : Field
{
    this(string name, Coord location)
    {
        this.name = name;
        this.location = location;
    }

    const string name;
    const Coord location;

    size_t[Portal] connectedPortals;
    Portal linkedTwin;

    override string toString()
    {
        return name;
    }

    override size_t toHash() const @safe pure nothrow
    {
        return cast(size_t)name[0] + cast(size_t)name[1];
    }

    bool isInnerPortal()
    {
        return location.x > 3 && location.x < maze.length - 4
            && location.y >3 && location.y < maze[0].length - 4;
    }

    bool isBeginning()
    {
        return name == "AA";
    }

    bool isExitPortal()
    {
        return name == "ZZ";
    }
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
        iteration: foreach(int y; 0 .. height)
        {
            auto element = lines[y][x];
            switch(element)
            {
                case '#':
                    maze[x][y] = new Wall;
                    break;
                case '.':
                    if(maze[x][y] is null) // Do not overwrite a portal.
                        maze[x][y] = new Path;
                    break;
                case ' ':
                    maze[x][y] = new Void;
                    break;
                default:
                    Coord c = Coord(x,y);
                    maze[x][y] = new Void;
                    foreach(move; movement)
                    {
                        auto newCoord = c.move(move);
                        if(!newCoord.isInBounds) continue;
                        if(lines[newCoord.y][newCoord.x] == '.')
                        {
                            auto opposite = c.move(move.opposite);
                            auto part2 = lines[opposite.y][opposite.x];
                            string name;
                            if(element < part2)
                            {
                                name = [element, part2];
                            }
                            else
                            {
                                name = [part2, element];
                            }
                            maze[newCoord.x][newCoord.y] = new Portal(name, Coord(newCoord.x, newCoord.y));
                            continue iteration;
                        }
                    }
            }
        }
    }
}


auto allFields()
{
    return maze.joiner;
}

auto allPortals()
{
    return allFields.filter!(f => cast(Portal)f).map!(f => cast(Portal)f);
}

void setUpMaze()
{
    parseFile();
    allPortals.each!(p => p.connectToOthers);
}

static immutable movement = [
    Coord(-1, 0),
    Coord(0, -1),
    Coord(1, 0),
    Coord(0, 1)
];

void findConnectedPortals(Portal portal, Coord start, Coord previousMove, size_t stepsTaken)
{
    stepsTaken += 1;
    auto possibleMovements = movement.filter!(m => !m.isOpposite(previousMove)).array;
    foreach(movement; possibleMovements)
    {
        auto nextStop = start.move(movement);
        if(!maze[nextStop.x][nextStop.y].canPass)
        {
            continue;
        }
        if(auto other = cast(Portal)maze[nextStop.x][nextStop.y])
        {  
            portal.connectedPortals[other] = stepsTaken;
            continue;
        }
        portal.findConnectedPortals(nextStop, movement, stepsTaken);
    }
}

void connectToOthers(Portal portal)
{
    portal.linkedTwin = findPortal(portal.name, portal);
    portal.findConnectedPortals(portal.location, Coord(0,0), 0);
}

Portal findPortal(string name, Portal other)
{
    foreach(y; 0 .. maze[0].length)
    {
        foreach(x; 0 .. maze.length)
        {
            auto portal = cast(Portal)maze[x][y];
            if(!portal) continue;
            if(portal is other) continue;
            if(portal.name == name) return portal;
        }
    }
    writeln("Could not find ", name);
    return null;
}

struct DimensionalPortal
{
    Portal portal;
    size_t layer;
}

size_t findShortestPath(Portal start, Portal finish, DimensionalPortal[] passedPortals, size_t layer)
{
    passedPortals = passedPortals ~ DimensionalPortal(start, layer);
    size_t shortest = 1_000_000;
    foreach(kvp; start.connectedPortals.byKeyValue)
    {
        auto portal = kvp.key;
        if(portal.isBeginning) continue;
        auto dp = DimensionalPortal(portal, layer);
        if(passedPortals.any!(pp => pp.portal is dp.portal && pp.layer == dp.layer))
        {
            continue;
        }
        size_t distanceToOther = kvp.value;
        size_t totalDistance = distanceToOther;
        if(portal !is finish)
        {
            auto passPortalsOnThisRoute = passedPortals ~ dp;
            size_t newLayer = portal.isInnerPortal ? layer + 1 : layer - 1;
            if(newLayer > 25) continue; // Too deep for me.
            totalDistance += 1; // Warp
            totalDistance += findShortestPath(portal.linkedTwin, finish, passPortalsOnThisRoute, newLayer);
        }
        else if(layer == 0)
        {
            //writeln("Found the goal");
        }
        else
        {
            writeln("Nope: ", layer);
            // Found the exit on the wrong layer.
            continue;
        }
        if(totalDistance < shortest)
        {
            shortest = totalDistance;
        }
    }
    return shortest;
}

size_t findShortestPath(Portal start, Portal finish)
{
    return findShortestPath(start, finish, [], 0);
}

void main()
{
    static if (is(typeof(registerMemoryErrorHandler)))
        registerMemoryErrorHandler(); 
    setUpMaze();
    /+foreach(portal; allPortals)
    {
        writeln(portal.name, " - ", portal.location, ": inner? ", portal.isInnerPortal);
    }+/
    //writeln("Set up maze");
    auto start = findPortal("AA", null);
    //writeln(start);
    auto finish = findPortal("ZZ", null);
    findShortestPath(start, finish).writeln;
    //auto path = findPath(start, finish);
    //writeln(path.length);
}
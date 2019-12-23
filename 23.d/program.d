module program;

import std.array;
import std.algorithm;
import std.conv;
import std.stdio;
import computer;
import etc.linux.memoryerror;

void main()
{
    registerMemoryErrorHandler;
    auto input = File("input.txt", "r").byLine.front.
        splitter(",").map!(x => x.to!Int).array;
    auto router = new Router(input);
    router.routeMessages;
}
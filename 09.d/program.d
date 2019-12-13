module program;

import std;
import core.thread;
import game;
import computer;

void main()
{
    auto input = File("input.txt", "r").byLine.front.
        splitter(",").map!(x => x.to!Int).array;
    auto ai = new AI;
    auto computer = new Computer(input, ai);
    computer.run;
}
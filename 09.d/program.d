module program;

import std;
import computer;

void main()
{
    auto input = File("input.txt", "r").byLine.front.
        splitter(",").map!(x => x.to!Int).array;
    //auto computer = new Computer([3,9,7,9,10,9,4,9,99,-1,8]);
    auto computer = new Computer(input);
    computer.run;
}
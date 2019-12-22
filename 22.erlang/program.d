import std;

//enum amountOfCards = 119315717514047L;
enum amountOfCards = 10007;
enum file = "input.txt";

void main()
{
    //size_t[] cards = iota(amountOfCards).array;
    auto instructions = File(file).byLineCopy.array;
    for(long end = 0; end < amountOfCards; end++)
    {
        long position = end;
        foreach(line; instructions.retro)
        {
            if(line.startsWith("deal with increment "))
            {
                auto increment = line[20..$].to!size_t;
                position = position.dealWithIncreament(increment);
            }
            else if(line.startsWith("cut "))
            {
                auto amount = line[4 .. $].to!long;
                position = position.cutCards(amount);
            }
            else if(line == "deal into new stack")
            {
                position = position.reverseOrder;
            }
            else
            {
                assert(false, "Unknown line: "~ line);
            }
        }
        writeln(position);
        
    }
}

long reverseOrder(long position)
{
    return (amountOfCards - 1)  - position;
}

long cutCards(long position, long n)
{
    return (position + n + amountOfCards) % amountOfCards;
}

long dealWithIncreament(long position, size_t n)
{
    while(position % n != 0)
    {
        position = position + amountOfCards;
    }
    return position / n;
}
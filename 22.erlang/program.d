import std;

void main()
{
    size_t amountOfCards = 119315717514047;
    size_t[] cards = iota(amountOfCards).array;
    auto instructions = File("input.txt").byLineCopy.array;
    foreach(line; File("input.txt").byLineCopy)
    {
        if(line.startsWith("deal with increment "))
        {
            auto increment = line[20..$].to!size_t;
            cards = cards.dealWithIncreament(increment);
        }
        else if(line.startsWith("cut "))
        {
            auto amount = line[4 .. $].to!long;
            cards = cards.cutCards(amount);
        }
        else if(line == "deal into new stack")
        {
            cards = cards.reverseOrder;
        }
        else
        {
            assert(false, "Unknown line: "~ line);
        }
    }
    foreach(i, j; cards)
    {
        if(j == 2019)
        {
            writeln(i);
        }
    }
}

size_t[] reverseOrder(size_t[] cards)
{
    return cards.retro.array;
}

size_t[] cutCards(size_t[] cards, long n)
{
    while(n < 0)
    {
        n = n + cards.length.to!long;
    }
    return cards[n .. $] ~ cards[0 .. n];
}

size_t[] dealWithIncreament(size_t[] cards, size_t n)
{
    size_t[] dealtCards = new size_t[cards.length];
    size_t i = 0;
    foreach(j, _; cards)
    {
        dealtCards[i] = cards[j];
        i = (i + n) % cards.length;
    }
    return dealtCards;
}
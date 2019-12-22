import std;
import std.experimental.checkedint;
import etc.linux.memoryerror;

alias Long = Checked!long;
//alias Instruction = Long delegate(Long);

Long putIntoCardBounds(Long x)
{
    while(x >= amountOfCards)
    {
        x -= amountOfCards;
    }
    while(x < 0)
    {
        x += amountOfCards;
    }
    return x;
}

/+
Long signAfterMultiplying(Long a, Long b)
{
    bool isANegative = a < 0;
    bool isBNegative = b < 0;
    if(isANegative && isBNegative)
    {
        return Long(1L);
    }
    if(!isANegative && !isBNegative)
    {
        return Long(1L);
    }
    return Long(-1L);
}
+/

Long limitMultiplicationBetweenCardBounds(Long a, Long b)
{
    if(b > a) return limitMultiplicationBetweenCardBounds(b, a);
    if(b == 0) return Long(0);
    auto absA = Long(abs(a.get));
    auto absB = Long(abs(b.get));
    //writeln("|A| ", a);
    //writeln("|B| ", b);
    auto amountOfTimesAFitIntoCards = amountOfCards/ absA.get;
    //writeln("AOTAFIC ", amountOfTimesAFitIntoCards);
    if(absB < amountOfTimesAFitIntoCards) return a * b;
    auto overshootWhenApplyingAToFitIntoCards = amountOfCards % absA.get;
    //writeln("OWAATFIC ", overshootWhenApplyingAToFitIntoCards);
    auto amountOfTimesBCanFillTheCardsWithA = absB / amountOfTimesAFitIntoCards;
    //writeln("AOTBCFTCWA ", amountOfTimesBCanFillTheCardsWithA);
    auto totalOvershoot = limitMultiplicationBetweenCardBounds(
        Long(overshootWhenApplyingAToFitIntoCards),
        Long(amountOfTimesBCanFillTheCardsWithA));
    totalOvershoot = putIntoCardBounds(-totalOvershoot);
    //writeln("Total overshoot ", totalOvershoot);
    auto amountOfTimesBStillNeedsToBeApplied = absB % amountOfTimesAFitIntoCards;
    //writeln("AOTBSNTOBA ", amountOfTimesBStillNeedsToBeApplied);
    auto result = 
        limitMultiplicationBetweenCardBounds(
                absA, 
                amountOfTimesBStillNeedsToBeApplied) 
        + totalOvershoot;
    return putIntoCardBounds(result);// * signAfterMultiplying(a, b));
}

unittest
{
    auto result = limitMultiplicationBetweenCardBounds(Long(5), Long(3));
    assert(result == 5);

    result = limitMultiplicationBetweenCardBounds(Long(3), Long(5));
    assert(result == 5);

    result = limitMultiplicationBetweenCardBounds(Long(1), Long(7));
    writeln(result);
    assert(result == 7);
}

struct Equation
{
    static Equation unity = Equation(Long(1), Long(0));

    // f(x) = a x + b
    Long a;
    Long b;

    static Equation opCall(Long a, Long b)
    {
        Equation eq;
        eq.a = a;
        eq.b = b;
        return eq;
    }

    unittest
    {
        auto eq = Equation.unity;
        eq = eq(Equation(Long(5), Long(7)));
        assert(eq.a == 5);
        writeln(eq);
        assert(eq.b == 7);
        eq = eq(Equation.unity);
        assert(eq.a == 5);
        assert(eq.b == 7);
    }

    Equation opCall(Equation other)
    {
        auto newA = limitMultiplicationBetweenCardBounds(a, other.a);
        Long newB = putIntoCardBounds(b + limitMultiplicationBetweenCardBounds(a, other.b));
        return Equation(newA, newB);
    }

    unittest
    {
        auto eq = Equation(Long(1), Long(2));
        eq = eq(Equation(Long(3), Long(5)));
        assert(eq.a == 3);
        assert(eq.b == 7);
        eq = Equation(Long(3), Long(5))(Equation(Long(1), Long(2)));
        assert(eq.a == 3);
        assert(eq.b == 1);
    }

    unittest
    {
        auto f = Equation(Long(2), Long(3));
        auto g = Equation(Long(5), Long(7));
        auto fg = f(g);
        assert(fg.a == 0);
        writeln(fg);
        assert(fg.b == 7);
        auto gf = g(f);
        assert(gf.a == 0);
        assert(gf.b == 2);
    }

    Long opCall(Long position)
    {
        writeln("A:", a);
        writeln("B:", b);
        return putIntoCardBounds(limitMultiplicationBetweenCardBounds(a, position) + b);
        //return (a * position + b) % amountOfCards;
    }
}

abstract class Instruction
{
    Long apply(Long position);
    Long applyForward(Long position);

    Equation opCall(Equation other);
}

class DealWithIncrement : Instruction
{
    this(size_t increment)
    {
        _increment = increment;
    }

    private size_t _increment;

    override Long apply(Long position)
    {
        while(position % _increment != 0)
        {
            position = position + amountOfCards;
        }
        return Long(position.get / _increment.to!long);
        //return position.dealWithIncreament(_increment);
    }

    override Long applyForward(Long position)
    {
        position *=  _increment;
        return Long(position % amountOfCards);
    }

    override Equation opCall(Equation other)
    {
        // Forward
        auto thisEquation = Equation(Long(_increment.to!long), Long(0));
        return thisEquation(other);
    }
}

class CutCards : Instruction
{
    this(Long amount)
    {
        _amount = amount;
    }

    private Long _amount;

    override Long apply(Long position)
    {
        return cutCards(position, _amount);
    }

    override Long applyForward(Long position)
    {
        return cutCards(position, -_amount);
    }

    private static Long cutCards(Long position, Long n)
    {
        return (position + n + amountOfCards) % amountOfCards;
    }

    override Equation opCall(Equation other)
    {
        // Forward
        auto thisEquation = Equation(Long(1), Long(amountOfCards - _amount).putIntoCardBounds);
        return thisEquation(other);
    }
}

class ReverseOrder : Instruction
{
    static Long reverseOrder(Long position)
    {
        return (amountOfCards - 1)  - position;
    }

    override Long apply(Long position)
    {
        return reverseOrder(position);
    }

    override Long applyForward(Long position)
    {
        return reverseOrder(position);
    }

    override Equation opCall(Equation other)
    {
        // Both forward and backward
        auto thisEquation = Equation(Long(-1).putIntoCardBounds, Long(amountOfCards - 1));
        return thisEquation(other);
    }
}

Instruction[] parseInstructions(string[] input)
{
    auto instructions = new Instruction[input.length];
    foreach(i, line; input)
    {
        if(line.startsWith("deal with increment "))
        {
            auto increment = line[20..$].to!size_t;
            instructions[i] = new DealWithIncrement(increment);
            //position = position.dealWithIncreament(increment);
        }
        else if(line.startsWith("cut "))
        {
            auto amount = line[4 .. $].to!long;
            instructions[i] = new CutCards(Long(amount));
            //position = position.cutCards(amount);
        }
        else if(line == "deal into new stack")
        {
            instructions[i] = new ReverseOrder;
            //position = position.reverseOrder;
        }
        else
        {
            assert(false, "Unknown line: "~ line);
        }
    }
    return instructions;
}

version(unittest)
{
    enum amountOfCards = 10;
    enum file = "test.txt";
    void main(){writeln("Tests completed");}
}
else
{
    //enum amountOfCards = 119315717514047L;
    enum amountOfCards = 10007;
    enum file = "input.txt";
    void main()
    {
        registerMemoryErrorHandler();
        auto instructions = File(file).byLineCopy.array.parseInstructions;
        Long position = 2496;
        Long amountOfIterations = 101741582076661L;
        //writeln(amountOfCards - amountOfIterations);
        enum amountOfRuns = 1;//8192 * 4;
        //Long[] shifts = new Long[amountOfRuns];
        //Long[] positions = new Long[amountOfRuns];
        //Long positionBefore = position;
        for(Long end = 0; end < amountOfRuns; end++)
        {
            position = instructions.applyAll(position);
        }
        writeln("Legitly: ", position);
        auto eq = composeEquation(instructions);
        auto result = eq(Long(2019));
        //auto result = eq(position);
        writeln("Linearly: ", result);
        writeln("Dan.");
    }
}

Long applyAll(Instruction[] instructions, Long position)
{
    //int i = 0;
    foreach(line; instructions.retro)
    {
        //i++;
        position = line.apply(position);
    }
    return position;
}

Equation composeEquation(Instruction[] instructions)
{
    Equation equation = Equation.unity;
    foreach(line; instructions)
    {
        equation = line(equation);
    }
    return equation;
}

Long reverseOrder(Long position)
{
    return (amountOfCards - 1)  - position;
}

Long dealWithIncreament(Long position, size_t n)
{
    while(position % n != 0)
    {
        position = position + amountOfCards;
    }
    return Long(position / n.to!long);
}
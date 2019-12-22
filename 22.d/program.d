import std;
import std.experimental.checkedint;
import etc.linux.memoryerror;

alias Long = Checked!long;

/// Reset the number such that x e [0, amountOfCards)
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

/++ 
    Simple multiply function:
        c = a * b
        c e [0, amountOfCards)
    Prevents overflow in the process,
+/
Long limitMultiplicationBetweenCardBounds(Long a, Long b)
{
    if(b > a) return limitMultiplicationBetweenCardBounds(b, a);
    if(b == 0) return Long(0);
    auto absA = Long(abs(a.get));
    auto absB = Long(abs(b.get));
    auto amountOfTimesAFitIntoCards = amountOfCards/ absA.get;
    if(absB < amountOfTimesAFitIntoCards) return a * b;
    auto overshootWhenApplyingAToFitIntoCards = amountOfCards % absA.get;
    auto amountOfTimesBCanFillTheCardsWithA = absB / amountOfTimesAFitIntoCards;
    auto totalOvershoot = limitMultiplicationBetweenCardBounds(
        Long(overshootWhenApplyingAToFitIntoCards),
        Long(amountOfTimesBCanFillTheCardsWithA));
    totalOvershoot = putIntoCardBounds(-totalOvershoot);
    auto amountOfTimesBStillNeedsToBeApplied = absB % amountOfTimesAFitIntoCards;
    auto result = 
        limitMultiplicationBetweenCardBounds(
                absA, 
                amountOfTimesBStillNeedsToBeApplied) 
        + totalOvershoot;
    return putIntoCardBounds(result);
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

/++
    Struct representing a first-order polynomal equation: f(x) = a x + b
    We abuse the linearity of the problem: 
        if g(x) = f o f(x)
        then g o g(x) = (f o f)(f o f)(x) = f(f(f(f(x))))
    This allows us to calculate the shuffling in O(1).
+/
struct Equation
{
    /// Unity equation f(x) = x. Used for initial inputs.
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

    /++
        Returns the function which is the other function applied before this is applied.
            f(x) = this
            g(x) = other
            h(x) = f(g(x)) = this(other)
    +/
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


    /// Supplies the function argument x to the function. 
    /// Returns y = a x + b; y e [0, amountOfCards)
    Long opCall(Long position)
    {
        return putIntoCardBounds(limitMultiplicationBetweenCardBounds(a, position) + b);
    }

}

/++
    Abstract base class representing a shuffle instruction.
    An instruction can heuristically apply a shuffle forward
    or apply a shuffle backward (default).
    They can also be applied as an equation to other operations.
+/
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
        }
        else if(line.startsWith("cut "))
        {
            auto amount = line[4 .. $].to!long;
            instructions[i] = new CutCards(Long(amount));
        }
        else if(line == "deal into new stack")
        {
            instructions[i] = new ReverseOrder;
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
    enum amountOfCards = 119315717514047L;
    enum file = "input.txt";
    void main()
    {
        registerMemoryErrorHandler();
        auto instructions = File(file).byLineCopy.array.parseInstructions;
        Long position = 2020;
        Long amountOfIterations = 101741582076661L;
        // For some reason we cycle every (# card - 1).
        // Our algorithm works "Forward". As in, given an initial position, 
        // we calculate the final position of the card.
        // The second question is backwards. Given a final position,
        // calculate what card ended up there.
        // We abuse the fact that our suffling is eventually cyclic in C.
        // Going backward X steps is going forward C - X steps.
        amountOfIterations = (amountOfCards -1) - amountOfIterations;
        auto eq = composeEquation(instructions);
        auto collection = hackEquations(eq);
        auto greatEquation = buildTheGreatEquation(collection, amountOfIterations);
        writeln("The great equation: ", greatEquation);
        Long result = 2020L;
        Long input = greatEquation(result);
        writeln("Answer :", input);
        writeln("Done.");
    }
}

/// Heuristically apply all instructions to find the previous position 
/// (card if the first iterstion) that was slit into the current position.
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

/// Compose the linear equation corresponding to all shuffles.
Equation composeEquation(Instruction[] instructions)
{
    Equation equation = Equation.unity;
    foreach(line; instructions)
    {
        equation = line(equation);
    }
    return equation;
}

/// Return the array of equations applied once, twice, four times, eight times, etc.
Equation[64] hackEquations(Equation eq)
{
    Equation[64] output;
    output[0] = eq;
    foreach(i; 1.. 64)
    {
        output[i] = output[i-1](output[i-1]);
    }
    return output;
}

/++
    Given the amount of iterations, compose the equation representing
    all of the shuffles.
+/
Equation buildTheGreatEquation(Equation[64] collection, Long amountOfIterations)
{
    long aoi = amountOfIterations.get;
    writeln("Blue: ", aoi);
    Equation greatEquation = Equation.unity;
    foreach(bit; 0 .. 64)
    {
        if(aoi & 1L << bit)
        {
            //writeln("Putting bit ", bit, " with decimal value ", 1L << bit);
            greatEquation = collection[bit](greatEquation);
        }
    }
    return greatEquation;
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
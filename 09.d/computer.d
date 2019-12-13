module computer;

import std.concurrency;
import game : AI;

alias Int  = long;

class Computer
{
    this(Int[] program, AI ai)
    {
        _program = program;
        _ai = ai;
    }

    void run()
    {
        Int cursor = 0;
        while(true)
        {
            auto instruction = _program[cursor];
            Int operation = instruction % 100;
            Int[3] modes = [
                getMode(instruction, 1),
                getMode(instruction, 2),
                getMode(instruction, 3)
            ];
            auto op = Op(cursor, modes);
            switch(operation)
            {
                case 1:
                    replace(op, getAddedValue(op));
                    cursor += 4;
                    break;
                case 2:
                    replace(op, getMultipliedValue(op));
                    cursor += 4;
                    break;
                case 3:
                    valueToReplace(op.read!1) = readInput();
                    cursor += 2;
                    break;
                case 4:
                    writeOutput(getElement(op.read!1));
                    cursor += 2;
                    break;
                case 5:
                    cursor = jumpIfTrue(op);
                    break;
                case 6:
                    cursor = jumpIfFalse(op);
                    break;
                case 7:
                    replace(op, lessThan(op));
                    cursor += 4;
                    break;
                case 8:
                    replace(op, equals(op));
                    cursor += 4;
                    break;
                case 9:
                    _relativeBase += getElement(op.read!1);
                    cursor += 2;
                    break;
                case 99:
                    return;
                default:
                    import std.conv: to;
                    assert(false, "Unknown operation " ~ operation.to!string);
            }
        }
    }

    private Int[] _program;
    private Int[Int] _memory;
    private Int _relativeBase = 0;
    private AI _ai;

    private Int asMemoryIndex(Int index)
    {
        return (index -  cast(Int)(_program.length));
    }

    private Int readValue(Int index)
    {
        if(index < _program.length)
        {
            return _program[index];
        }
        Int memoryIndex = asMemoryIndex(index);
        if(memoryIndex in _memory)
            return _memory[memoryIndex];
        return 0;
    }

    private Int getElement(Read read)
    {
        switch(read.mode)
        {
            case 0:
                return readValue(readValue(read.index));
            case 1:
                return readValue(read.index);
            case 2:
                return readValue(_relativeBase + readValue(read.index));
            default:
                assert(false, "Unknown mode when getting element");
        }
    }

    private Int getNewValue(const Op op, Int delegate(Int, Int) operation)
    {
        return operation(
            getElement(op.read!1),
            getElement(op.read!2)
        );
    }

    private Int getAddedValue(Op op) 
    {
        return getNewValue(op, (x, y) => x + y);
    }

    private Int getMultipliedValue(Op op) 
    {
        return getNewValue(op, (x, y) => x * y);
    }

    private Int lessThan(Op op)
    {
        return getNewValue(op, (x, y) => x < y ? 1 : 0);
    }

    private Int equals(Op op)
    {
        return getNewValue(op, (x, y) => x == y ? 1 : 0);
    }

    private Int jumpIf(Op op, bool delegate(Int) pred)
    {
        if(pred(getElement(op.read!1)))
        {
            return getElement(op.read!2);
        }
        return op.cursor + 3;
    }

    private Int jumpIfTrue(Op op)
    {
        return jumpIf(op, x => x != 0);
    }

    private Int jumpIfFalse(Op op) 
    {
        return jumpIf(op, x => x == 0);
    }

    private static Int getMode(Int instruction, Int n)
    {
        switch(n)
        {
            case 1:
                return (instruction % 1_000)/100;
            case 2:
                return (instruction % 10_000)/1_000;
            case 3:
                return (instruction)/10_000;
            default:
                assert(false, "Unknown nth mode");
        }
    }

    private ref Int valueToReplace(Read read)
    {
        auto indexToReplace = readValue(read.index);
        if(read.mode == 2)
        {
            indexToReplace += _relativeBase;
        }
        if(indexToReplace < _program.length)
        {
            return _program[indexToReplace];
        }
        Int memoryIndex = asMemoryIndex(indexToReplace);
        if(!(memoryIndex in _memory)) _memory[memoryIndex] = 0;
        return _memory[memoryIndex];
    }

    private void replace(Op op, Int newValue)
    {
        valueToReplace(op.read!3) = newValue;
    }

    private Int readInput()
    {
        return _ai.decide;
    }

    private void writeOutput(Int value)
    {
        _ai.receive(value);
    }

    private struct Op
    {
        Int cursor;
        Int[3] modes;

        Read read(Int offset)() const
        {
            return Read(cursor+offset, modes[offset-1]);
        }
    }

    private struct Read
    {
        Int index;
        Int mode;
    }
}

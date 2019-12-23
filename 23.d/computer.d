module computer;

import core.time;
import std.concurrency;
import std.stdio;

alias Int  = long;

class Router
{
    private Tid _address;

    this(Int[] program)
    {
        _address = thisTid;
        foreach(i; 0 .. 50)
        {
            _network ~= spawn(&createComputer, program.idup, _address);
        }
        foreach(i; 0 .. 50)
        {
            _network[i].send(cast(Int)i);
        }
        _nat = spawn(&nat, _address);
    }

    private Tid[] _network;
    private Tid _nat;

    void routeMessages()
    {
        bool done = false;
        while(!done)
        {
            bool activity = receiveTimeout(50.msecs,
                (Message m) { 
                    //writeln("Received ", m);
                    if(m.destination == 255)
                    {
                        _nat.send(m);
                    }
                    else _network[m.destination].send(m);
                },
                (Kill _) {
                    done = true;
                },
                (Variant v) {
                    writeln("Received unknown message ", v);
                }
            );
            if(!activity) 
            {
                _nat.send(NetworkIdle());
            }
        }
    }
}

void nat(Tid owner)
{
    Int lastYValueSent;
    Message cachedMessage;
    bool done;
    while(!done)
    {
        receive(//Timeout(1.msecs.
            (Message m) {
                writeln("Received message");
                cachedMessage = m;
            },
            (NetworkIdle _) {
                writeln("Network is idle!");
                if(cachedMessage.y == lastYValueSent)
                {
                    writeln("Sent twice: ", lastYValueSent);
                    owner.send(Kill());
                    done = true;
                }
                lastYValueSent = cachedMessage.y;
                owner.send(Message(0, cachedMessage.x, cachedMessage.y));
            },
            (Variant v) {
                writeln("Received unknown message ", v);
            }
        );
    }
}

struct Message
{
    Int destination = -1;
    Int x = -1;
    Int y = -1;
}

struct NetworkIdle
{

}

struct Kill
{
    bool _;
}

void createComputer(immutable Int[] program, Tid owner)
{
    writeln("Creating computer");
    auto computer = new Computer(program.dup, owner);
    computer.run;
}

class Computer
{
    this(Int[] program, Tid network)
    {
        _program = program;
        _network = network;
    }

    void run()
    {
        writeln("Running computer");
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
                    assert(false, "Unknown operation");
            }
        }
    }

    private Tid _network;
    private Int[] _program;
    private Int[Int] _memory;
    private Int _relativeBase = 0;

    private Int readValue(Int index)
    {
        if(index < _program.length)
        {
            return _program[index];
        }
        Int memoryIndex = cast(Int)(index - _program.length);
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
        Int memoryIndex = cast(Int)(indexToReplace - _program.length);
        _memory[memoryIndex] = 0;
        return _memory[memoryIndex];
    }

    private void replace(Op op, Int newValue)
    {
        valueToReplace(op.read!3) = newValue;
    }

    bool _receivedAddress;
    private Int[] _messageQueue;
    private Int readInput()
    {
        import core.time;
        //writeln("Reading input");
        do
        {
            receiveTimeout(1.msecs, 
                (Int i) {
                    writeln("Received address");
                    _messageQueue ~= i;
                    _receivedAddress = true;
                },
                (Message m) { 
                    writeln("Computer received ", m);
                    _messageQueue ~= [m.x, m.y];
                 },
                 (Variant v) {
                     import std.stdio : writeln;
                     writeln("Received unknown message ", v);
                 }
            );
        }
        while(!_receivedAddress);
        //writeln("Peeked at the mailbox");
        if(_messageQueue.length == 0)
        {
            return -1;
        }
        Int input = _messageQueue[0];
        _messageQueue = _messageQueue[1 .. $];
        return input;
    }

    private Message _accumulatedOutput;
    private void writeOutput(Int value)
    {
        //writeln("Writing output ", value, " with accumulation ", _accumulatedOutput);
        if(_accumulatedOutput.destination == -1)
        {
            _accumulatedOutput.destination = value;
            return;
        }
        if(_accumulatedOutput.x == -1)
        {
            _accumulatedOutput.x = value;
            return;
        }
        _accumulatedOutput.y = value;
        writeln("Sending ", _accumulatedOutput, " to ", _network);
        _network.send(_accumulatedOutput);
        _accumulatedOutput = Message();
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

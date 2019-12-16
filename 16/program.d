module program;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;

void main()
{
    readInput.processMessage.writeln;
}

string readInput()
{
    return File("input.txt", "r").byLine().array().front;
}

string processMessage(string text)
{
    int[] input = text.toIntArray;
    size_t offset = text[0 .. 7].to!size_t;
    int[] extendedInput = [];
    foreach(i; 0 .. 10_000)
    {
        extendedInput ~= input;
    }
    extendedInput = extendedInput[offset .. $];

    int[] output = fft(extendedInput, 100);
    char[8] result;
    foreach(j; 0 .. 8)
    {
        result[j] = output[j].to!string[0];
    }
    return result.to!string;
}

int[] toIntArray(string input)
{
    return input.map!(c => c.toInt).array;
}

int toInt(dchar c)
{
    return c - '0';
}

int[] fft(int[] input, size_t iterations)
{
    int[] output = input;
    foreach(i; 0 .. iterations)
    {
        output = phaseTransform(output);
    }
    return output;
}

int[] phaseTransform(in int[] input)
{
    int[] output = new int[input.length];
    output[$-1] = input[$-1];
    foreach_reverse(index, ref outputValue; output[0 .. $-1])
    {
        int sum = input[index] + output[index + 1];
        sum = sum % 10;
        if(sum < 0) sum = -sum;
        outputValue = sum;
    }
    return output;
}
import std.algorithm;
import std.array;
import std.conv;
import std.stdio;

void main()
{
    //"19617804207202209144916044189917".processMessage.writeln;
    readInput.processMessage.writeln;
}

string readInput()
{
    return File("input.txt", "r").byLine().array().front;
}

dstring processMessage(string text)
{
    int[] input = text.toIntArray;
    //size_t offset = text[0 .. 7].to!size_t;
    size_t offset = 0;
    int[] output = fft(input, 100);
    int[] solution = output[offset .. offset+8];
    return solution.map!(i => i.to!string).joiner.array;
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
    foreach(index, ref outputValue; output)
    {
        outputValue = getOutputDigit(input, index);
    }
    return output;
}

int getOutputDigit(in int[] input, size_t outputIndex)
{
    int sum = 0;
    foreach(i; 0 .. input.length)
    {
        sum += getInputDigit(input, i, outputIndex);
    }
    sum = sum % 10;
    if(sum < 0) return -sum;
    return sum;
}

int getInputDigit(in int[] input, size_t inputIndex, size_t outputIndex)
{
    return getPatternValue(inputIndex, outputIndex) * input[inputIndex];
}

int getPatternValue(size_t inputIndex, size_t outputIndex)
{
    size_t patternIndex = (inputIndex+1)/(outputIndex+1) % pattern.length;
    return pattern[patternIndex];
}

enum int[4] pattern = [0, 1, 0, -1];

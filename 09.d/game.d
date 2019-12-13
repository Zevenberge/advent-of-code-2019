module game;

import computer : Int;
import std;

struct Coordinate
{
    Int x;
    Int y;
}

struct Pixel
{
    Coordinate coordinate;
    Int value;
}

Pixel readPixel(Int x)
{
    Int y = receiveOnly!Int;

    Int value = receiveOnly!Int;
    return Pixel(Coordinate(x, y), value);
}

Int getValue(Int[Coordinate] values, Coordinate coord)
{
    if(coord in values)
    {
        return values[coord];
    }
    return 0;
}

bool done(Int[Coordinate] values)
{
    return values.byValue.filter!(v => v == .block).count == 0;
}

void printScore(Int[Coordinate] values)
{
    if(values.done) writeln("Done :D");
    Int score = values.getValue(Coordinate(-1, 0));
    writeln("Score: ", score);
}

enum wall = 1;
enum block = 2;
enum ball = 4;
enum paddle = 3;
enum empty = 0;

void draw(Int[Coordinate] values)
{
    enum wall = '█';
    enum block = '#';
    enum ball = 'O';
    enum paddle = '-';
    enum empty = ' ';
    values.printScore;
    foreach(y; 0 .. 23)
    {
        foreach(x; 0 .. 45)
        {
            switch(values.getValue(Coordinate(x, y)))
            {
                case 1:
                    write(wall);
                    break;
                case 2:
                    write(block);
                    break;
                case 3:
                    write(paddle);
                    break;
                case 4:
                    write(ball);
                    break;
                default:
                    write(empty);
                    break;
            }
        }
        writeln;
    }
}

struct State
{
    Coordinate ball;
    Coordinate paddle;
}

class AI
{
    private int _count;
    private Int[3] _input;
    private Int[Coordinate] _values;

    void receive(Int input)
    {
        _input[_count] = input;
        ++_count;
        if(_count == 3)
        {
            _count = 0;
            auto pixel = Pixel(Coordinate(_input[0], _input[1]), _input[2]);
            _values[pixel.coordinate] = pixel.value;
        }
        _values.printScore;
    }

    Int decide()
    {
        State state;
        foreach(t; _values.byKeyValue)
        {
            if(t.value == .paddle) state.paddle = t.key;
            if(t.value == .ball) state.ball = t.key;
        }
        if(state.ball.x > state.paddle.x)
        {
            return 1;
        }
        else if(state.ball.x == state.paddle.x)
        {
            return 0;
        }
        else
        {
            return -1;
        }
    }
}
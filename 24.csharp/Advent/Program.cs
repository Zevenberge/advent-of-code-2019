using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Advent
{
    class Program
    {
        static void Main(string[] args)
        {
            var states = new List<int>();
            var input = ReadInput();
            int representation = RepresentationOf(input);
            while(!states.Any(s => s == representation))
            {
                states.Add(representation);
                input = Advance(input);
                representation = RepresentationOf(input);
            }
            Console.WriteLine(representation);
            Print(input);
        }

        static void Print(List<List<Tile>> area)
        {
            foreach(var line in area)
            {
                foreach(var tile in line)
                {
                    if(tile == Tile.Bug)
                        Console.Write("#");
                    else
                        Console.Write(".");
                }
                Console.WriteLine();
            }
        }

        static List<List<Tile>> ReadInput()
        {
            var lines = File.ReadAllLines("input.txt");
            var output = new List<List<Tile>>();
            foreach(var line in lines)
            {
                var list = new List<Tile>();
                foreach(var character in line)
                {
                    if(character == '.')
                    {
                        list.Add(Tile.Empty);
                    }
                    else if(character == '#')
                    {
                        list.Add(Tile.Bug);
                    }
                    else
                    {
                        Console.WriteLine($"Unknown character {character}");
                    }
                }
                output.Add(list);
            }
            return output;
        }

        static List<List<Tile>> Advance(List<List<Tile>> input)
        {
            var output = new List<List<Tile>>();
            int y = 0;
            foreach(var line in input)
            {
                int x = 0;
                var list = new List<Tile>();
                foreach(var tile in line)
                {
                    var amountOfBugs = AmountOfBugsSurrounding(input, x, y);
                    if(tile == Tile.Bug)
                    {
                        if(amountOfBugs == 1)
                        {
                            list.Add(Tile.Bug);
                        }
                        else 
                        {
                            list.Add(Tile.Empty);
                        }
                    }
                    else // tile == Tile.Empty
                    {
                        if(amountOfBugs == 1 || amountOfBugs == 2)
                        {
                            list.Add(Tile.Bug);
                        }
                        else
                        {
                            list.Add(Tile.Empty);
                        }
                    }
                    x++;
                }
                y++;
                output.Add(list);
            }
            return output;
        }

        static int AmountOfBugsSurrounding(List<List<Tile>> input, int x, int y)
        {
            var lowerBound = 0;
            var upperBounds = input.Count - 1;
            int IsBugAt(int nextX, int nextY)
            {
                if(nextX < lowerBound || nextX > upperBounds ||
                    nextY < lowerBound || nextY > upperBounds)
                    return 0;
                return input[nextY][nextX] == Tile.Bug ? 1 : 0;
            }
            int amountOfBugs = 0;
            amountOfBugs += IsBugAt(x-1, y  );
            amountOfBugs += IsBugAt(x+1, y  );
            amountOfBugs += IsBugAt(x  , y-1);
            amountOfBugs += IsBugAt(x  , y+1);
            return amountOfBugs;
        }

        static int RepresentationOf(List<List<Tile>> area)
        {
            int width = area.Count;
            int representation = 0;
            int i = 0;
            foreach(var line in area)
            {
                foreach(var tile in line)
                {
                    if(tile == Tile.Bug)
                    {
                        Console.WriteLine($"{i}: {1 << i}") ;
                        representation += 1 << i;
                    }
                    i++;
                }
            }
            return representation;
        }
    }

    enum Tile
    {
        Empty,
        Bug
    }
}

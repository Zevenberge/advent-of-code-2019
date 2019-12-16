import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.lang.Process;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Stack;
import java.util.stream.Collector;
import java.util.stream.Collectors;

public class Program {
    public static void main(String[] args) throws IOException {
        Runtime runtime = Runtime.getRuntime();
        Process process = runtime.exec("./intcode");
        Reader output = new InputStreamReader(process.getInputStream());
        Writer input = new OutputStreamWriter(process.getOutputStream());
        Program program = new Program(output, input);
        program.run();
    }

    private static final int FAILURE = -1;

    private static final int NORTH = 1;
    private static final int SOUTH = 2;
    private static final int WEST = 3;
    private static final int EAST = 4;

    private static final int WALL = 0;
    private static final int MOVE = 1;
    private static final int OXYGEN = 2;

    public Program(Reader output, Writer input) {
        this.output = new BufferedReader(output);
        this.input = new BufferedWriter(input);
        this.position = new Coordinate(0, 0);
        this.walls = new ArrayList<>();
        this.walkablePositions = new Stack<>();
    }

    private final BufferedReader output;
    private final BufferedWriter input;

    public void run() throws IOException {
        walkablePositions.add(this.position);
        walk(-1);
        printWalls();
        fillWithOxigen();
    }

    private void fillWithOxigen() {
        int minutes = 0;
        while(thereIsStillSomeRoomsWithoutOxigen()) {
            for(Coordinate roomWithOxigen: getRoomsWithOxigen()) {
                for(Coordinate other: walkablePositions) {
                    other.fill(roomWithOxigen);
                }
            }
            minutes++;
        }
        System.out.print(minutes);
    }

    private boolean thereIsStillSomeRoomsWithoutOxigen()
    {
        for(Coordinate room : walkablePositions) {
            if(!room.hasOxigen()) return true;
        }
        return false;
    }

    private List<Coordinate> getRoomsWithOxigen()
    {
        return walkablePositions.stream().filter(c -> c.hasOxigen()).collect(Collectors.toList());
    }

    private void printWalls() {
        List<Integer> xValues = walls.stream().map(w -> w.x).collect(Collectors.toList());
        List<Integer> yValues = walls.stream().map(w -> w.y).collect(Collectors.toList());
        int minX = Collections.min(xValues);
        int maxX = Collections.max(xValues);
        int minY = Collections.min(yValues);
        int maxY = Collections.max(yValues);
        for (int y = minY; y <= maxY; ++y) {
            for (int x = minX; x <= maxX; ++x) {
                Coordinate coord = new Coordinate(x, y);
                if (coord.isOrigin()) {
                    System.out.print('X');
                } else if (coord.equals(position)) {
                    System.out.print("*");
                } else if (walls.contains(coord) && walkablePositions.contains(coord)) {
                    System.out.print('!');
                } else if (walls.contains(coord)) {
                    System.out.print('#');
                } else if (walkablePositions.contains(coord)) {
                    System.out.print('.');
                } else {
                    System.out.print(' ');
                }
            }
            System.out.println();
        }
    }

    private Coordinate position;
    private List<Coordinate> walls;
    private List<Coordinate> walkablePositions;

    private void walk(int lastMovement) throws IOException {
        List<Integer> directions = composePossibleMovements(lastMovement);
        for (int direction : directions) {
            Coordinate newPosition = this.position.move(direction);
            execute(direction);
            String line = output.readLine();
            int response = Integer.parseInt(line);
            if(response == WALL) {
                assert(!walkablePositions.contains(newPosition));
                walls.add(newPosition);
                continue;
            }
            this.position = newPosition;
            this.walkablePositions.add(this.position);
            if(response == OXYGEN) {
                System.out.println("Found");
                this.position.isOxigenSource();
                response = MOVE;
            }
            if(response == MOVE) {
                assert(!walls.contains(this.position));
                walk(direction);
                execute(inverse(direction));
                output.readLine();
                this.position = this.position.moveBack(direction);
            } else {
                assert(false);
            }
            
        }
    }

    private List<Integer> composePossibleMovements(int lastMovement) {
        List<Integer> directions = new ArrayList<>();
        if(lastMovement != SOUTH) {
            directions.add(NORTH);
        }
        if(lastMovement != NORTH) {
            directions.add(SOUTH);
        }
        if(lastMovement != EAST) {
            directions.add(WEST);
        }
        if(lastMovement != WEST) {
            directions.add(EAST);
        }
        return directions;
    }

    private static int inverse(int direction)
    {
        switch (direction) {
            case NORTH:
                return SOUTH;
            case SOUTH:
                return NORTH;
            case EAST:
                return WEST;
            case WEST:
                return EAST;
            default:
                assert(false);
                return -1;
        }
    }

    private void execute(int direction) throws IOException
    {
        input.write(""+direction+"\n");
        input.flush();
    }

    private static class Coordinate
    {
        public Coordinate(int x, int y) {
            this.x = x;
            this.y = y;
        }
        public final int x;
        public final int y;

        private boolean oxigen;
        public boolean hasOxigen() {
            return oxigen;
        }

        public void isOxigenSource() {
            oxigen = true;
        }

        public void fill(Coordinate other) {
            if(other.oxigen && isAdjescent(other)) {
                oxigen = true;
            }
        }

        public Coordinate move(int movement) {
            switch (movement) {
                case NORTH:
                    return new Coordinate(x, y + 1);
                case SOUTH:
                    return new Coordinate(x, y - 1);
                case EAST:
                    return new Coordinate(x + 1, y);
                case WEST:
                    return new Coordinate(x - 1, y);
                default:
                    assert(false);
                    return this;
            }
        }

        public Coordinate moveBack(int movementForward) {
            return move(inverse(movementForward));
        }

        public boolean isOrigin() {
            return x == 0 && y == 0;
        }

        public boolean isAdjescent(Coordinate other) {
            return Math.abs(x - other.x) + Math.abs(y - other.y) == 1;
        }

        @Override
        public boolean equals(Object obj) {
            if(!(obj instanceof Coordinate)) return false;
            Coordinate that = (Coordinate)obj;
            return this.x == that.x && this.y == that.y;
        }

        @Override
        public String toString() {
            return "(" + x + "," + y + ")";
        }

        @Override
        public int hashCode() {
            return 10_000 * x + y;
        }
    }
}
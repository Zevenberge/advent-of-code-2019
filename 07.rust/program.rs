use std::convert::TryInto;

trait Output {
   fn write(&mut self, number: i32);
}

trait Input {
   fn read(&mut self) -> i32;
}

struct Pipe {
   messages: [i32; 32],
   sentIndex: Cursor,
   receivedIndex: Cursor,
}

impl Pipe {
   fn new (default: i32) -> Pipe {
      Pipe {messages: [default; 32], sentIndex: 0, receivedIndex: 0}
   }
}

impl Output for Pipe {
   fn write(&mut self, number: i32) {
      println!("{}", number);
      self.messages[self.sentIndex] = number;
      self.sentIndex = self.sentIndex + 1;
   }
}

impl Input for Pipe {
   fn read(&mut self) -> i32 {
      let output: i32 = self.messages[self.receivedIndex];
      self.receivedIndex = self.receivedIndex + 1;
      output
   }
}

struct StdOut;

impl Output for StdOut {
   fn write(&mut self, number: i32) {
      println!("{}", number);
   }
}

struct Amplifier<'a> {
   computer: &'a Computer<'a>,
   phaseSetting: i32,
}

type Modes = [i32; 3];
type Cursor = usize;

struct Computer<'a> {
   program: &'a mut [i32],
   input: &'a mut Input,
   output: &'a mut Output,
}

trait ConvertToUsize {
   fn toUsize(self) -> usize;
}

impl ConvertToUsize for i32 {
   fn toUsize(self) -> usize {
      self.try_into().unwrap()
   }
}

fn getElement(program: &[i32], index: usize, mode: i32) -> i32 {
   if mode == 0 {
      program[program[index].toUsize()]
   } else {
      program[index]
   }
}

fn getNewValue<F>(program: &[i32], cursor: Cursor, modes: Modes, 
   operation: F) -> i32 
   where F : Fn(i32, i32) -> i32 {
   operation(
      getElement(program, cursor+1, modes[0]),
      getElement(program, cursor+2, modes[1])
   )
}

fn getAddedValue(program: &[i32], cursor: Cursor, modes: Modes) -> i32 {
   getNewValue(program, cursor, modes, |x, y| x + y)
}

fn getMultipliedValue(program: &[i32], cursor: Cursor, modes: Modes) -> i32 {
   getNewValue(program, cursor, modes, |x, y| x * y)
}

fn jumpIf<F>(program: &[i32], cursor: Cursor, modes: Modes, 
   pred: F) -> Cursor 
   where F : Fn(i32) -> bool {
   if pred(getElement(program, cursor+1, modes[0])) {
      getElement(program, cursor+2, modes[1]).toUsize()
   } else {
      cursor + 3
   }
}

fn jumpIfTrue(program: &[i32], cursor: Cursor, modes: Modes) -> Cursor {
   jumpIf(program, cursor, modes, |e| e != 0)
}

fn jumpIfFalse(program: &[i32], cursor: Cursor, modes: Modes) -> Cursor {
   jumpIf(program, cursor, modes, |e| e == 0)
}

fn lessThan (program: &[i32], cursor: Cursor, modes: Modes) -> i32 {
   getNewValue(program, cursor, modes, |i, j| if i < j { 1 } else { 0 } )
}

fn equals (program: &[i32], cursor: Cursor, modes: Modes) -> i32 {
   getNewValue(program, cursor, modes, |i, j| if i == j { 1 } else { 0 } )
}

fn getMode (instruction: i32, n: i32) -> i32 {
   match n {
      1 => (instruction % 1000)/100,
      2 => (instruction % 10_000)/1000,
      3 => instruction/10_000,
      _ => -1,
   }
}

impl Computer<'_> {

   fn run(&mut self) {
      let mut cursor = 0;
      loop {
         let instruction = self.program[cursor];
         let operation = instruction % 100;
         let modes = [
            getMode(instruction, 1),
            getMode(instruction, 2),
            getMode(instruction, 3)
         ];
         match operation {
            1 => {
               self.replace(cursor, getAddedValue(self.program, cursor, modes));
               cursor = cursor + 4;
            },
            2 => {
               self.replace(cursor, getMultipliedValue(self.program, cursor, modes));
               cursor = cursor + 4;
            },
            3 => {
               let int = self.input.read();
               self.program[self.program[cursor+1].toUsize()] = int;
               cursor = cursor + 2;
            },
            4 => {
               self.output.write(getElement(self.program, cursor+1, modes[0]));
               cursor = cursor + 2;
            },
            5 => {
               cursor = jumpIfTrue(self.program, cursor, modes);
            },
            6 => {
               cursor = jumpIfFalse(self.program, cursor, modes);
            },
            7 => {
               self.replace(cursor, lessThan(self.program, cursor, modes));
               cursor = cursor + 4;
            },
            8 => {
               self.replace(cursor, equals(self.program, cursor, modes));
               cursor = cursor + 4;
            },
            99 => {
               break;
            },
            _ => {
               println!("NOOOOO");
            }
         }
      }
   }

   fn replace(&mut self, cursor: Cursor, newValue: i32) {
      self.program[self.program[cursor+3].toUsize()] = newValue;
   }
}

fn main() {
   let mut program = [1101,100,-1,4,0];
   let mut program = vec![3,225,1,225,6,6,1100,1,238,225,104,0,1102,45,16,225,2,65,191,224,1001,224,-3172,224,4,224,102,8,223,223,1001,224,5,224,1,223,224,223,1102,90,55,225,101,77,143,224,101,-127,224,224,4,224,102,8,223,223,1001,224,7,224,1,223,224,223,1102,52,6,225,1101,65,90,225,1102,75,58,225,1102,53,17,224,1001,224,-901,224,4,224,1002,223,8,223,1001,224,3,224,1,224,223,223,1002,69,79,224,1001,224,-5135,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,102,48,40,224,1001,224,-2640,224,4,224,102,8,223,223,1001,224,1,224,1,224,223,223,1101,50,22,225,1001,218,29,224,101,-119,224,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1101,48,19,224,1001,224,-67,224,4,224,102,8,223,223,1001,224,6,224,1,223,224,223,1101,61,77,225,1,13,74,224,1001,224,-103,224,4,224,1002,223,8,223,101,3,224,224,1,224,223,223,1102,28,90,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,7,226,677,224,102,2,223,223,1005,224,329,1001,223,1,223,8,226,677,224,1002,223,2,223,1005,224,344,101,1,223,223,8,226,226,224,1002,223,2,223,1006,224,359,101,1,223,223,1008,677,226,224,1002,223,2,223,1005,224,374,1001,223,1,223,108,677,677,224,1002,223,2,223,1005,224,389,1001,223,1,223,1107,226,677,224,1002,223,2,223,1006,224,404,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,419,1001,223,1,223,7,677,226,224,1002,223,2,223,1005,224,434,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,449,101,1,223,223,7,226,226,224,102,2,223,223,1005,224,464,101,1,223,223,108,677,226,224,102,2,223,223,1005,224,479,1001,223,1,223,1007,677,226,224,1002,223,2,223,1006,224,494,1001,223,1,223,1007,677,677,224,1002,223,2,223,1006,224,509,1001,223,1,223,107,677,677,224,1002,223,2,223,1005,224,524,101,1,223,223,1108,226,677,224,102,2,223,223,1006,224,539,1001,223,1,223,8,677,226,224,102,2,223,223,1005,224,554,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,569,1001,223,1,223,107,677,226,224,102,2,223,223,1005,224,584,1001,223,1,223,108,226,226,224,102,2,223,223,1006,224,599,1001,223,1,223,107,226,226,224,1002,223,2,223,1006,224,614,1001,223,1,223,1108,677,226,224,1002,223,2,223,1005,224,629,1001,223,1,223,1107,677,677,224,102,2,223,223,1005,224,644,1001,223,1,223,1008,677,677,224,102,2,223,223,1005,224,659,101,1,223,223,1107,677,226,224,1002,223,2,223,1006,224,674,101,1,223,223,4,223,99,226];
   let mut input = Pipe::new(5);
   let mut output = StdOut{};
   let mut computer = Computer {
      program: &mut program, 
      input: &mut input, 
      output: &mut output};
   computer.run();
}

use std::convert::TryInto;

trait Output {
   fn write(&mut self, number: i32);
}

trait Input {
   fn canRead(&self) -> bool;
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
      self.messages[self.sentIndex] = number;
      self.sentIndex = self.sentIndex + 1;
   }
}

impl Input for Pipe {
   fn canRead(&self) -> bool {
      self.sentIndex > self.receivedIndex
   }

   fn read(&mut self) -> i32 {
      let output: i32 = self.messages[self.receivedIndex];
      self.receivedIndex = self.receivedIndex + 1;
      output
   }
}

type Modes = [i32; 3];
type Cursor = usize;

struct Computer<'a> {
   program: &'a mut [i32],
   input: &'a mut Input,
   output: &'a mut Output,
   cursor: Cursor,
   done: bool,
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
      if self.cursor == 0 {
         println!("Starting computer");
      } else {
         println!("Resuming program");
      }
      loop {
         let instruction = self.program[self.cursor];
         let operation = instruction % 100;
         let modes = [
            getMode(instruction, 1),
            getMode(instruction, 2),
            getMode(instruction, 3)
         ];
         match operation {
            1 => {
               self.replace(self.cursor, getAddedValue(self.program, self.cursor, modes));
               self.cursor = self.cursor + 4;
            },
            2 => {
               self.replace(self.cursor, getMultipliedValue(self.program, self.cursor, modes));
               self.cursor = self.cursor + 4;
            },
            3 => {
               if self.input.canRead() {
                  let int = self.input.read();
                  self.program[self.program[self.cursor+1].toUsize()] = int;
                  self.cursor = self.cursor + 2;
               }
               else {
                  break;
               }
            },
            4 => {
               self.output.write(getElement(self.program, self.cursor+1, modes[0]));
               self.cursor = self.cursor + 2;
            },
            5 => {
               self.cursor = jumpIfTrue(self.program, self.cursor, modes);
            },
            6 => {
               self.cursor = jumpIfFalse(self.program, self.cursor, modes);
            },
            7 => {
               self.replace(self.cursor, lessThan(self.program, self.cursor, modes));
               self.cursor = self.cursor + 4;
            },
            8 => {
               self.replace(self.cursor, equals(self.program, self.cursor, modes));
               self.cursor = self.cursor + 4;
            },
            99 => {
               self.done = true;
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

fn puzzleInput() -> [i32; 527] {
   // 25
   //[3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
   // 34
   //[3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
   // 527
   [3,8,1001,8,10,8,105,1,0,0,21,42,67,84,109,122,203,284,365,446,99999,3,9,1002,9,3,9,1001,9,5,9,102,4,9,9,1001,9,3,9,4,9,99,3,9,1001,9,5,9,1002,9,3,9,1001,9,4,9,102,3,9,9,101,3,9,9,4,9,99,3,9,101,5,9,9,1002,9,3,9,101,5,9,9,4,9,99,3,9,102,5,9,9,101,5,9,9,102,3,9,9,101,3,9,9,102,2,9,9,4,9,99,3,9,101,2,9,9,1002,9,3,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,99]
}

fn buildPipes(setting: Vec<i32>) -> Vec<Pipe> {
   let mut pipes : Vec<Pipe> = setting.iter().map(|s| {
      let mut pipe = Pipe::new(-999);
      pipe.write(*s);
      pipe
   }).collect();
   pipes[0].write(0);
   pipes
}
/*
fn buildComputers(pipes: Vec<Pipe>) -> Vec<Computer> {
   let mut computers : Vec<Computer> = Vec::new();
   let amountOfPipes = pipes.len();
   for i in 0 .. amountOfPipes {
      let mut program = puzzleInput();
      let mut computer = Computer {
         program: &mut program,
         input: &mut pipes[i],
         output: &mut pipes[(i+1)%amountOfPipes],
         cursor: 0,
         done: false
      };
      computers.push(computer);
   }
   computers;
}*/
/*
fn runUntilCompletion(computers: &Vec<&mut Computer>) {
   loop {
      for computer in computers {
         computer.run();
      }
      if computers[4].done {
         break;
      }
   }
}*/

struct State {
   program: [i32; 527 ],
   cursor: Cursor,
   done: bool
}

fn buildState(amount: usize) -> Vec<State> {
   let mut states: Vec<State> = Vec::new();
   for _ in 0 .. amount {
      states.push(State {
         program: puzzleInput(),
         cursor: 0,
         done: false
      })
   }
   states
}

fn findThrusterSignalForSetting(setting: Vec<i32>) -> i32 {
   let mut pipe = Pipe::new(-666);
   pipe.write(setting[0]);
   pipe.write(0);
   let mut lastValue: i32 = 0;
   let mut firstRound: bool = true;
   let amount = setting.len();
   let mut states = buildState(amount);

   loop {
      for i in 0 .. amount {
         let mut output = Pipe::new(-666);
         let mut cursor = states[i].cursor;
         let mut done = states[i].done;
         let mut program = states[i].program;
         {
            let mut computer = Computer {
               program: &mut program,
               input: &mut pipe,
               output: &mut output,
               cursor: cursor,
               done: done
            };
            computer.run();
            cursor = computer.cursor;
            done = computer.done;
         }
         states[i].program = program;
         states[i].cursor = cursor;
         states[i].done = done;
         pipe = Pipe::new(-666);
         if i < amount - 1 && firstRound {
            pipe.write(setting[i+1]);
         }
         if output.canRead() {
            loop {
               lastValue = output.read();
               pipe.write(lastValue);
               if !output.canRead() {
                  break;
               }
            }
         }
      }
      firstRound = false;
      if states[4].done {
         break;
      }
   }
   lastValue
}

fn findThrusterSignal() -> i32 {
   let phaseSettings = [5,6,7,8,9];
   let mut possibleSettings = permutations(phaseSettings.to_vec());
   let mut maxThrusterSignal: i32 = 0;
   for setting in possibleSettings {
      let thrusterSignal = findThrusterSignalForSetting(setting);
      if thrusterSignal > maxThrusterSignal {
         maxThrusterSignal = thrusterSignal;
      }()
   }
   maxThrusterSignal
}

fn main() {
   let maxThrusterSignal = findThrusterSignal();
   println!("Max truster signal: {}", maxThrusterSignal);
}

fn permutations(array: Vec<i32>) -> Vec<Vec<i32>> {
   let mut output : Vec<Vec<i32>> = Vec::new();
   let length = array.len();
   if length == 1 {
      output.push(array);
   }
   else {
      for x in 0 .. length {
         let mut rest : Vec<i32> = Vec::new();
         let elem = array.get(x);
         for y in 0 .. length {
            if x != y {
               rest.push(unbox(array.get(y)));
            }
         }
         let restPermutations = permutations(rest);
         for perm in restPermutations {
            let mut permuation : Vec<i32> = Vec::new();
            permuation.push(unbox(elem));
            for pelem in perm {
               permuation.push(pelem);
            }
            output.push(permuation);
         }
      }
   }
   output
}

fn unbox(i: Option<&i32>) -> i32 {
   match i {
      Some(x) => *x,
      None => 99
   }
}
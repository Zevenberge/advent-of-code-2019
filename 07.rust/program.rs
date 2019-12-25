use std::convert::TryInto;
use std::sync::mpsc::channel;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::Sender;
use std::thread;

type Modes = [i32; 3];
type Cursor = usize;

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

struct Computer<'a> {
   program: &'a mut [i32],
   input: Receiver<i32>,
   output: Sender<i32>,
}

impl Computer<'_> {

   fn run(&mut self) {
      let mut cursor: Cursor = 0;
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
               let int = self.input.recv().unwrap();
               self.program[self.program[cursor+1].toUsize()] = int;
               cursor = cursor + 2;

            },
            4 => {
               self.output.send(getElement(self.program, cursor+1, modes[0])).unwrap();
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
               self.output.send(-1).unwrap();
               //drop(self.input);
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

fn spawnComputer(receiver: Receiver<i32>) -> (Sender<i32>, Receiver<i32>) {
   let (tx, rx) = channel();
   let secondSender = tx.clone();
   thread::spawn(move || {
      let mut program = puzzleInput();
      let mut computer = Computer {
         program: &mut program,
         input: receiver,
         output: secondSender,
      };
      computer.run();
   });
   (tx, rx)
} 

fn findThrusterSignalForSetting(setting: Vec<i32>) -> i32 {
   let (mut transmitter, mut receiver) = channel();
   let transmitterToA = transmitter.clone();
   for s in setting {
      transmitter.send(s).unwrap();
      let (tx, rx) = spawnComputer(receiver);
      transmitter = tx;
      receiver = rx;
   }

   transmitterToA.send(0).unwrap();
   let mut lastVal = 0;
   loop {
      let val = receiver.recv().unwrap();
      if val != -1 {
         lastVal = val;
      } else {
         break;
      }
      match transmitterToA.send(val) {
         Ok(_x) => {},
         Err(_x) => break,
      }
   }
   lastVal
}

fn findThrusterSignal() -> i32 {
   let phaseSettings = [5,6,7,8,9];
   let possibleSettings = permutations(phaseSettings.to_vec());
   let mut maxThrusterSignal: i32 = 0;
   for setting in possibleSettings {
      let thrusterSignal = findThrusterSignalForSetting(setting);
      if thrusterSignal > maxThrusterSignal {
         maxThrusterSignal = thrusterSignal;
      }
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
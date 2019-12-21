import scala.collection.mutable.ArrayBuffer
//import scala.sys.process
import java.lang.Process
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

class Computer {
    private var _process : Process = null
    private var _output : BufferedReader = null
    private var _input : BufferedWriter = null
    def start() : Unit = {
        val runtime = Runtime.getRuntime()
        _process = runtime.exec("./intcode 2> log.txt | tee output.txt")
        val output = new InputStreamReader(_process.getInputStream())
        _output = new BufferedReader(output)
        val input = new OutputStreamWriter(_process.getOutputStream())
        _input = new BufferedWriter(input)
    }

    def send(message : Int) : Unit = {
        _input.write(""+message+"\n");
        _input.flush();
    }

    def sendChar(message : Char) : Unit = {
        send(message.asInstanceOf[Int])
    }

    def sendLine(message : String) : Unit = {
        print("$ ")
        println(message)
        for(c <- message) {
          sendChar(c)
        }
        sendChar('\n')
    }

    def receive() : Int = {
        _output.readLine().toInt
    }

    def readChar() : Char = {
      receive().asInstanceOf[Char]
    }

    def readLine() : String = {
      val text = ArrayBuffer.empty[Char]
      var char = ' '
      while(char != '\n') {
        char = readChar()
        text += char
      }
      return text.mkString("")
    }

    def readErrors() : Unit = {
      println("Gathering errors...")
      val errorReader = new InputStreamReader(_process.getErrorStream())
      val anotherErrorReader = new BufferedReader(errorReader)
      var line = anotherErrorReader.readLine()
      while(line != null)
      {
        println(line)
        line = anotherErrorReader.readLine()
      }
      println("Error report finished")
    }
}

class Springdroid(computer: Computer) {

  def command(cmd: String, value: Char, register: Char) : Unit = {
    computer.sendLine(s"$cmd $value $register")
  }

  def not(value: Char, register: Char) : Unit = {
    command("NOT", value, register)
  }

  def and(value: Char, register: Char) : Unit = {
    command("AND", value, register)
  }

  def or(value: Char, register: Char) : Unit = {
    command("OR", value, register)
  }
  
  def walk() : Unit = {
    computer.sendLine("WALK")
  }
}

object Program {
  def main(args: Array[String]): Unit = {
      val computer = new Computer()
      computer.start()
      print(computer.readLine())
      val droid = new Springdroid(computer)
      droid.not('C', 'J');
      droid.not('B', 'T');
      droid.or('T', 'J');
      droid.not('A', 'T');
      droid.or('T', 'J');
      droid.and('D', 'J');
      droid.walk();
      try {
        var line : String = "Hello"
        while(!line.isEmpty) {
          line = computer.readLine()
          print(line);
        }
      }
      catch {
        case _: Throwable => computer.readErrors()
      }
      //computer.send(1001)
      //computer.send(825)
      
    //println("Hello, world!")
  }
}

case class Point(x: Int, y: Int)

class Greetert(prefix: String, suffix: String) {
  def greet(name: String): Unit =
    println(prefix + name + suffix)
}

trait Greeter {
  def greet(name: String): Unit
}

//val animals = ArrayBuffer.empty[Greeter]
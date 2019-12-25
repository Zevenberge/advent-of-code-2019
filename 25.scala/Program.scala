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
        _process = runtime.exec("./intcode")
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
      val output = receive()
      if(output > 255)
      {
        println(output)
      }
      output.asInstanceOf[Char]
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
      val errorReader = new InputStreamReader(_process.getErrorStream())
      val anotherErrorReader = new BufferedReader(errorReader)
      var line = anotherErrorReader.readLine()
      while(line != null)
      {
        println(line)
        line = anotherErrorReader.readLine()
      }
    }
}

object Program {
  def main(args: Array[String]): Unit = {
      val computer = new Computer()
      computer.start()
      var line = computer.readLine()
      while(line != null) {
        print(line)
        if(line == "Command?\n") {
          val input = scala.io.StdIn.readLine().trim()
          computer.sendLine(input);
        }
        line = computer.readLine()
      }
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
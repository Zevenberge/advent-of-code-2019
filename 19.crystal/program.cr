class Intcode
    def initialize()
        @process = Process.new("./intcode", input: Process::Redirect::Pipe, output: Process::Redirect::Pipe)
    end

    def send(number : Int32)
        text = "#{number}"
        @process.input.write(text.to_slice)
    end

    def receive()
        result = @process.output.read_line.to_i32
        result
    end
end

def runIntcode()
    Intcode.new
end

intcode = runIntcode()
puts intcode.receive()
intcode.send(10)
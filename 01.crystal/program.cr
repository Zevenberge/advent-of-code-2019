def fuel(mass : Int32)
   (mass / 3).to_i32 - 2
end

lines = File.read_lines("input.txt")
numbers = lines.map{ |s| s.to_i32() }
fuels = numbers.map!{ |n| fuel n }
total_fuel = fuels.sum
puts total_fuel


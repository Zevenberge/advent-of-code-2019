def fuel(mass : Int32)
   first_fuel = (mass / 3).to_i32 - 2
   unless first_fuel <= 0
      first_fuel + fuel first_fuel
   else
      0
   end
end

lines = File.read_lines("input.txt")
numbers = lines.map{ |s| s.to_i32() }
fuels = numbers.map!{ |n| fuel n }
total_fuel = fuels.sum
puts total_fuel


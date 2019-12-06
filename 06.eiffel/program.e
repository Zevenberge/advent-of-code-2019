class 
    PROGRAM

create
    make

feature {NONE}
   read_file
       local
	   input_file: PLAIN_TEXT_FILE
       do
           create input_file.make_open_read ("input.txt")
	   from
               input_file.read_line
	   until
               input_file.exhausted
	   loop
	       parse_line(input_file.last_string)
               input_file.read_line
           end
       end

   parse_line(line: STRING)
       local
           planet_from: SPACE
	   planet_to: SPACE
       do
           planet_from := stellation.get_planet(line.substring(1, 3))
           planet_to := stellation.get_planet(line.substring(5, 7))
	   planet_to.set_previous(planet_from)
       end

   count_orbits : INTEGER
       local
           planet : SPACE
       do
           Result := 0
           across 1 |..| stellation.count as i
           loop
               planet := stellation.planets.item(i.item)
               Result := Result + planet.count_orbits
           end
       end

    find_hops_to_santa : INTEGER
       local
          you : SPACE
	  santa : SPACE
	  ancestor : SPACE
       do
          you := stellation.get_planet("YOU")
	  santa := stellation.get_planet("SAN")
          ancestor := you.find_common_ancestor(santa)
	  Result := (you.count_orbits - 1 - ancestor.count_orbits) + (santa.count_orbits - 1 - ancestor.count_orbits)
       end

feature
    stellation : STELLATION


    make
        local
	   steps: INTEGER
        do 
	    create stellation.make
	    read_file
	    steps := find_hops_to_santa
            print(steps)
        end

end



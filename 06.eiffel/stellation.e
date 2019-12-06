class
    STELLATION
create
    make
feature
    planets: ARRAY[SPACE]
    count: INTEGER
    make
        do
	    create planets.make(1, 1500)
	    count := 0
	end

    get_planet (name: STRING) : SPACE
        local
	    exists: BOOLEAN
	    new_planet: PLANET
	    new_com : COM
        do
	    exists := false
	    if name.is_equal("COM") then
                create new_com.make(name)
		Result := new_com
	    else
		create new_planet.make(name)
		Result := new_planet
	    end
	    if count > 0 then
	        across 1 |..| count as i
                loop
                    if name.is_equal(planets.item(i.item).name) then
		        Result := planets.item(i.item)
		        exists := true
		    end
                end
            end
	    if not exists then
		count := count + 1
		planets.put(Result, count)
            end
	end
end

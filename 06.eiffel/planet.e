class
    PLANET
inherit
    SPACE
        redefine
	    set_previous
    end
create
    make
feature
    make (n: STRING)
        local
            com: COM
        do
            create com.make("???")
            previous := com
            set_name(n)
        end
    previous: SPACE
    set_previous (prev : SPACE)
        do
	    previous := prev
	end
    count_orbits: INTEGER
        do
	    Result := 1 + previous.count_orbits
	end
end

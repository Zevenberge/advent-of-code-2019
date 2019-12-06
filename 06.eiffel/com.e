class
    COM
inherit
    SPACE
--        redefine
--	    count_orbits
--    end
create
    make
feature
    make (n: STRING)
        do
            set_name(n)
        end
    count_orbits: INTEGER
        do
	    Result := 0
	end
end

class
    COM
inherit
    SPACE
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
    find_common_ancestor(other: SPACE):SPACE
        do
            Result := Current
        end
end

deferred class
   SPACE
feature
   name:STRING
   set_name(n: STRING)
       do
           name := n
       end
   count_orbits: INTEGER
       deferred
       end
   find_common_ancestor(other: SPACE):SPACE
       deferred
       end
   set_previous (prev: SPACE) do end
end

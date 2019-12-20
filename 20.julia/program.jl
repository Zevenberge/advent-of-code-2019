f(x, y) = x + y

Nullable{T} = Union{T, Nothing}

struct Point{T}
    x::T
    y::T
end

function g(x,y)
    if x < y
        return x * y
    elseif x == y
        return 1
    else
        return 0
    end
end

function h(i)
    sum = 0
    for j in 1:10, k in 2:5
        sum += (i - k) * j
    end
    return sum
end

mutable struct Bar
    baz
    qux::Float64
end

local x :: Nullable{Int} = 2
x = nothing
x = 5
tup = (1, "foo")
println(tup[2])
println(f(3, 2))
println(g(3, 2))
println(h(10))

println("Hello world")
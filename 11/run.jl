function readstones(path)
    parse.(Int, split(read(path, String), " "))
end

function blink(stones, iterations)
    cache = Dict{Tuple{Integer,Integer}, Integer}()
    res = 0
    for s in stones
        res += blink_rec(s, iterations, cache)
    end
    res
end


function blink_rec(s::Integer, it::Integer, cache::Dict{Tuple{Integer,Integer}, Integer})::Integer
    cached = get(cache, (s,it), nothing)
    if cached !== nothing
        return cached
    end
    res = 0
    if it == 0
      res = 1
    elseif s == 0
      res = blink_rec(1, it-1, cache)
    else 
        n = ndigits(s)
        if iseven(n)
            nh = n ÷ 2
            d = 10^nh
            l = s ÷ d
            r = s - d*l
            res += blink_rec(l, it-1, cache)
            res += blink_rec(r, it-1, cache)
        else
            res = blink_rec(s*2024, it-1, cache)
        end
    end
    cache[(s,it)] = res
    res
end

function main()
    stones = readstones(ARGS[1])
    println("Task 1: $(blink(stones, 25))")
    println("Task 1: $(blink(stones, 75))")
end

@time main()


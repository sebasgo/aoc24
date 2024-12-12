function readmap(path)
    map = nothing
    for line in eachline(path)
       row = reshape(Vector{Char}(line), 1, :)
       map = map === nothing ? row : vcat(map, row)
    end
    map
end

const DIRS = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]

function score(x, map)
    @inbounds c = map[x]
    if c == '9'
        return Set([x]), 1
    end
    tops = Set{CartesianIndex}()
    rating = 0
    for dx in DIRS
        xn = x + dx
        if checkbounds(Bool, map, xn) && c+1 == @inbounds map[xn] 
            topsn, ratingn = score(xn, map)
            union!(tops, topsn)
            rating += ratingn
        end
    end
    return tops, rating
end

function main()
    map = readmap(open(ARGS[1]))
    totalscore = 0
    totalrating = 0
    for x in findall(c->c=='0', map)
        tops, rating = score(x, map)
        totalscore += length(tops)
        totalrating += rating
    end
    println("Task 1: $(totalscore)")
    println("Task 2: $(totalrating)")
end

@time main()

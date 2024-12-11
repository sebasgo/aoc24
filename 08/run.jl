function readmap()
    map = nothing
    for line in eachline(open(ARGS[1]))
       row = reshape(Vector{Char}(line), 1, :)
       map = map === nothing ? row : vcat(map, row)
    end
    map
end

function markantinodes!(freq, map, antinodes, all)
    coords = findall(f -> f == freq, map)
    len = length(coords)
    for i in 1:len
        for j in i+1:len
            x1 = coords[i]
            x2 = coords[j]
            d = x2 - x1
            if all
                for dir in -1:2:1
                    x = x1
                    while markantinode!(x, antinodes)
                        x += dir * d
                    end
                end
            else
                markantinode!(x1 - d, antinodes)
                markantinode!(x2 + d, antinodes)
           end
        end
    end
end

function markantinode!(x, antinodes)
    if checkbounds(Bool, antinodes, x)
        antinodes[x] = true
        return true
    end
    return false
end

function main()
    map = readmap()
    antinodes1 = falses(size(map))
    antinodes2 = falses(size(map))
    freqs = Set((f for f in map if f != '.'))
    for freq in freqs
        markantinodes!(freq, map, antinodes1, false)
        markantinodes!(freq, map, antinodes2, true)
    end
    println("Task 1: $(sum(antinodes1))")
    println("Task 1: $(sum(antinodes2))")
end

@time main()

function readmap()
    map = missing
    guard = missing
    for (y, line) in enumerate(eachline(open(ARGS[1])))
        row = reshape(Vector{Char}(line) .== '#', 1, :)
        if map === missing
            map = row
        else
            map = vcat(map, row)
        end
        x = findfirst('^', line)
        if x != nothing
            guard = CartesianIndex(y, x)
        end
    end
    map, guard
end

function inbounds(map, guard)
    all((1, 1) .<= Tuple(guard) .<= size(map))
end

function canmove(map, guard, dir)
    next = guard + dir
    if !inbounds(map, next)
        return true
    end
    !map[next]
end

function rotate(dir)
    map = Dict(
        CartesianIndex(-1,  0) => CartesianIndex( 0,  1),
        CartesianIndex( 0,  1) => CartesianIndex( 1,  0),
        CartesianIndex( 1,  0) => CartesianIndex( 0, -1),
        CartesianIndex( 0, -1) => CartesianIndex(-1,  0),
    )
    return map[dir]
end

function walk(map, guard)
    visited = zero(map)
    turns = Set{CartesianIndex}([])
    dir = CartesianIndex(-1, 0)
    while inbounds(map, guard)
        visited[guard] = true
        turned = false
        while !canmove(map, guard, dir)
            dir = rotate(dir)
            turned = true
        end
        if turned
            if guard in turns
                return visited, true
            end
            push!(turns, guard)
        end
        guard += dir
    end
    visited, false
end

function findloops(map, guard)
    loops = 0
    for pos in CartesianIndices(map)
        if map[pos]
            continue
        end
        newmap = copy(map)
        newmap[pos] = true
        _, loop = walk(newmap, guard)
        if loop
            loops += 1
        end
    end
    loops
end

function main()
    map, guard = readmap()
    visited, _ = walk(map, guard)
    println("Task 1: $(sum(visited))")
    println("Task 2: $(findloops(map, guard))")
    
end

@time main()
@time main()

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

function calc_price_all(map)
    visited = falses(size(map))
    price = [0, 0] 
    for x in CartesianIndices(map)
        if !visited[x]
            price += calc_price(x, map, visited)
        end
    end
    price
end

function calc_price(x, map, visited)
    area, perimeter, corners = calc_price_rec(x, map, visited)
    [area * perimeter, area * corners]
end

function calc_price_rec(x::CartesianIndex, map::Matrix{Char}, visited::BitMatrix)::Tuple{Integer, Integer, Integer}
    if visited[x]
        return 0, 0, 0
    end
    visited[x] = true
    area = 1
    perimeter = 0
    corners = count_corners(x, map)
    for dx in DIRS
        xn = x + dx
        if map[x] == get(map, xn, nothing)
            (area, perimeter, corners) = (area, perimeter, corners) .+ calc_price_rec(xn, map, visited)
        else
            perimeter += 1
        end
    end
    area, perimeter, corners
end

function count_corners(x::CartesianIndex, map::Matrix{Char})::Integer
    c = map[x]
    r = 0
    for yd=-1:2:1, xd=-1:2:1 
        ny = get(map, x + CartesianIndex(yd, 0), nothing)
        nx = get(map, x + CartesianIndex(0, xd), nothing)
        nxy = get(map, x + CartesianIndex(yd, xd), nothing)
        if c != ny && c != nx
            r+=1
        end
        if c == nx && c == ny && c != nxy
            r+=1
        end
    end
    r
end



function main()
    map = readmap(ARGS[1])
    prices = calc_price_all(map)
    println("Task 1: $(prices[1])")
    println("Task 2: $(prices[2])")
end

@time main()


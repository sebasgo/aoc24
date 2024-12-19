using Graphs
using SparseArrays

const MAP_SIZES = Dict("sample.txt" => 7, "input.txt" => 71)
const COUNTS = Dict("sample.txt" => 12, "input.txt" => 1024)

const DIRS = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]


function simulate(path)
    size = MAP_SIZES[path]
    m = trues(size, size)
    limit = COUNTS[path]
    lin = LinearIndices(m)
    g = nothing
    for (i, line) in enumerate(eachline(open(path)))
        x, y = parse.(Int, split(line, ',')) .+ 1
        m[y, x] = false
        if i == limit
            g = make_graph(m)
            len = shortest_path(m, g, lin)
            println("Task 1: $len")
        elseif i > limit
            strip_graph!(g, CartesianIndex(y, x), lin)
            len = shortest_path(m, g, lin)
            if len == 0
                println("Task 2: $(x-1),$(y-1) (Byte $i)")
                ppmap(m)
                return
            end
        end
    end
end

function strip_graph!(g, x, lin)
    for dx in DIRS
        n = x + dx
        if checkbounds(Bool, lin, n)
            rem_edge!(g, lin[x], lin[n])
            rem_edge!(g, lin[n], lin[x])
        end
    end
end

function ppmap(m)
    foreach(row -> println(join(map(c -> c ? "." : "#", row), "")), eachrow(m))
end

function make_graph(m)
    is = Vector{Int}()
    js = Vector{Int}()
    lin = LinearIndices(m)
    for x in CartesianIndices(m)
        if !m[x]
            continue
        end
        for dx in DIRS
            x2 = x + dx
            if !get(m, x2, false)
                continue
            end
            l = lin[x]
            l2 = lin[x2]
            push!(is, l)
            push!(js, l2)
            push!(is, l2)
            push!(js, l)
        end
    end
    SimpleGraph(sparse(is, js, ones(length(is))))
end

function shortest_path(m, g, lin)
    s = lin[1, 1]
    t = lin[end, end]
    edges = a_star(g, s, t)
    length(edges)
end
    

function main()
    path = ARGS[1]
    m = simulate(path)
end

@time main()

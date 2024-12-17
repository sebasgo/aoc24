using Graphs
using SparseArrays

struct Puzzle
    map::BitMatrix
    start::CartesianIndex{2}
    goal::CartesianIndex{2}
end

const DIRS = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]

function parse(path)
    m = nothing
    s = nothing
    g = nothing
    for (j, line) in enumerate(eachline(open(path)))
        row = reshape(Vector{Char}(line) .!= '#', 1, :)
        m = m === nothing ? row : vcat(m, row)
        if (i = findfirst('S', line)) !== nothing
            s = CartesianIndex(j, i)
        end
        if (i = findfirst('E', line)) !== nothing
            g = CartesianIndex(j, i)
        end
    end
    Puzzle(m, s, g)
end

function adjind(x, puzzle)
    rows = size(puzzle.map, 1)
    y, x = Tuple(x)
    4 * ((y-1) + rows * (x - 1)) + 1
end

function tilecoord(ind, puzzle)
    rows = size(puzzle.map, 1)
    t = div(ind - 1 , 4)
    x = div(t, rows) + 1
    y = t - rows * (x-1) + 1
    return CartesianIndex(y, x)
end

function make_graph_matrix(puzzle)
    n = 4 * prod(size(puzzle.map))
    println(n)
    is = Vector{Int}()
    js = Vector{Int}()
    vs = Vector{Int}()
    for x in CartesianIndices(puzzle.map)
        if !puzzle.map[x]
            continue
        end
        ai = adjind(x, puzzle)
        for i=0:3
            push!(is, ai+i)
            push!(is, ai+i)
            push!(js, ai+mod(i + 1, 4))
            push!(js, ai+mod(i - 1, 4))
            push!(vs, 1000)
            push!(vs, 1000)
        end
        for (i, dx) in enumerate(DIRS)
            i -= 1
            x2 = x + dx
            if !puzzle.map[x2]
                continue
            end
            ai2 = adjind(x2, puzzle)
            push!(is, ai+i)
            push!(is, ai2+i)
            push!(js, ai2+i)
            push!(js, ai+i)
            push!(vs, 1)
            push!(vs, 1)
        end
    end
    sparse(is, js, vs, n, n)
end

function print_seats(puzzle, coords)
    m = Matrix{Char}(undef, size(puzzle.map))
    for x in CartesianIndices(puzzle.map)
        m[x] = puzzle.map[x] ? '.' : '#'
    end
    for x in coords
        m[x] = 'O'
    end
    for row in eachrow(m)
        println(join(row, ""))
    end
end

function walk_pred!(ns, ds, i)
    push!(ns, i)
    for j in ds.predecessors[i]
        walk_pred!(ns, ds, j)
    end
end


function main()
    puzzle = parse(ARGS[1])
    w = make_graph_matrix(puzzle)
    g = SimpleGraph(w)
    ds = dijkstra_shortest_paths(g, adjind(puzzle.start, puzzle) + 3, w, allpaths=true)
    gai = adjind(puzzle.goal, puzzle)
    gai = gai + argmin(ds.dists[gai:gai+3]) - 1
    println("Task 1: $(ds.dists[gai])")
    k = Integer(ds.pathcounts[gai])
    ns = Vector{Integer}()
    walk_pred!(ns, ds, gai)
    coords = Set{CartesianIndex{2}}()
    for n in ns
        push!(coords, tilecoord(n, puzzle))
    end
    println("Task 2: $(length(coords))")
    print_seats(puzzle, coords)
end

@time main()

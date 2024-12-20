using Graphs
using SparseArrays

struct RaceTrack
    map::BitMatrix
    start::CartesianIndex
    finish::CartesianIndex
end


function read_race(path)
    map = nothing
    sx = sy = fx = fy = 1
    for (j, line) in enumerate(eachline(open(path)))
        row = reshape(Vector{Char}(line) .!= '#', 1, :)
        if (i = findfirst('S', line)) !== nothing
            sy, sx = j, i
        end
        if (i = findfirst('E', line)) !== nothing
            fy, fx = j, i
        end
        map = map === nothing ? row : vcat(map, row)
    end
    RaceTrack(map, CartesianIndex(sy, sx), CartesianIndex(fy, fx))
end

function build_track_graph(g, race)
    m = race.map
    l = LinearIndices(m)
    s = size(race.map)
    add_vertices!(g, prod(s))
    for y=2:s[1]-1, x=2:s[2]-1
        if all(m[y, x:x+1])
            add_edge!(g, l[y, x], l[y, x+1])
        end
        if all(m[y:y+1, x])
            add_edge!(g, l[y, x], l[y+1, x])
        end
    end
end

function collect_cheats(g, race)
    m = race.map
    l = LinearIndices(m)
    s = size(race.map)
    t0 = length(a_star(g, l[race.start], l[race.finish]))
    c = 0
    cs = Dict{Int, Int}()
    for j=2:s[1]-1, i=2:s[2]-1
        x = CartesianIndex(j, i)
        for dx in [CartesianIndex(1, 0), CartesianIndex(0, 1)]
            if m[x-dx] && !m[x] && m[x+dx]
                add_edge!(g, l[x-dx], l[x])
                add_edge!(g, l[x], l[x+dx])
                t = length(a_star(g, l[race.start], l[race.finish]))
                dt = t0 - t
                cs[dt] = get(cs, dt, 0) + 1
                if dt >= 100
                    c += 1
                end
                rem_edge!(g, l[x-dx], l[x])
                rem_edge!(g, l[x], l[x+dx])
            end
        end
    end
    display(sort(cs))
    c
end

function collect_more_cheats(g, race)
    m = race.map
    lin_indcs = LinearIndices(m)
    s = size(race.map)
    t0 = length(a_star(g, lin_indcs[race.start], lin_indcs[race.finish]))
    c = 0
    cs = Dict{Int, Int}()
    w = prepare_weights(g, race)
    candidates = Set{Tuple{CartesianIndex{2}, CartesianIndex{2}, Int}}()
    for x in CartesianIndices(m)
        if !m[x]
            continue
        end
        for x2 in CartesianIndices(m)
            if !m[x2]
                continue
            end
            d = sum(abs.(Tuple(x).-Tuple(x2)))
            if d >= 2 && d <= 20
                push!(candidates, x < x2 ? (x, x2, d) : (x2, x, d))
            end
        end
    end
    println(length(candidates))
    for (x, x2, d) in candidates
        lx = lin_indcs[x]
        lx2 = lin_indcs[x2]
        add_edge!(g, lx, lx2)
        @assert w[lx, lx2] == 0 "$(w[lx, lx2])"
        w[lx, lx2] = w[lx2, lx] = d
        # t = length(a_star(g, lin_indcs[race.start], lin_indcs[race.finish], w))
        ds = dijkstra_shortest_paths(g, lin_indcs[race.start], w)
        t = ds.dists[lin_indcs[race.finish]]
        dt = t0 - t
        cs[dt] = get(cs, dt, 0) + 1
        if dt >= 100
            c += 1
        end
        # println("cheat ", x, " ", x2, " -> ", t)
        rem_edge!(g, lx, lx2)
    end
    display(sort(cs))
    c
end

function prepare_weights(g, race)
    n = prod(size(race.map))
    is = Vector{Int}()
    js = Vector{Int}()
    for edge in edges(g)
        l, r = Tuple(edge)
        push!(is, l)
        push!(js, r)
        push!(is, r)
        push!(js, l)
    end
    sparse(is, js, ones(Int, length(is)), n, n)
end

function main()
    r = read_race(ARGS[1])
    l = LinearIndices(r.map)
    g = SimpleGraph()
    build_track_graph(g, r)
    # c = collect_cheats(g, r)
    # println("Task 1: $c")
    c = collect_more_cheats(g, r)
    println("Task 2: $c")
end

@time main()


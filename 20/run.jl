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
    c
end

function collect_more_cheats(g, race)
    m = race.map
    l = LinearIndices(m)
    cinds = CartesianIndices(m)
    s = size(race.map)
    t0 = length(a_star(g, l[race.start], l[race.finish]))
    c = 0
    cs = Dict{Int, Int}()
    ds = dijkstra_shortest_paths(g, l[race.finish])
    track = reverse(enumerate_paths(ds, l[race.start]))
    for i=1:length(track)
        for j=i+1:length(track)
            lx = track[i]
            lx2 = track[j]
            x = cinds[lx]
            x2 = cinds[lx2]
            d_track = ds.dists[lx] - ds.dists[lx2]
            d_cheat = sum(abs.(Tuple(x2 - x)))
            savings = d_track - d_cheat
            if 2 <= d_cheat <= 20 && savings > 0
                cs[savings] = get(cs, savings, 0) + 1
                if savings >= 100
                    c += 1
                end
            end
        end
    end
    c
end


function main()
    r = read_race(ARGS[1])
    l = LinearIndices(r.map)
    g = SimpleGraph()
    build_track_graph(g, r)
    c = collect_cheats(g, r)
    println("Task 1: $c")
    c = collect_more_cheats(g, r)
    println("Task 2: $c")
end

@time main()


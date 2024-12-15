using LinearAlgebra
using Profile

const RE=r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)"

function parse_line(line)
    parse.(Int, match(RE, line))
end

function move(x, v, steps, size)
    mod.(x .+ (steps.*v), size)
end

function calc_quadrants(size)
    h = div.((size .- 1), 2) .+ 1
    res = Array{Integer}(undef, 2, 2, 4)
    for i=0:1, j=0:1
        res[1, :, i+2j+1] = [i, j] .* h
        res[2, :, i+2j+1] = ([i, j] .+ 1) .* h .- 2

    end
    res
end

function get_quadrant(x, qs)
    for q in 1:4
        if all(qs[1, :, q] .<= x .<= qs[2, :, q])
            return q
        end
    end
    return 0
end

function ppmap(map)
    for row in eachrow(map)
        println(join([x > 0 ? "#" : " " for x in row], ""))
    end
end


function stddev(map)
    idxs = findall(x->x>0, map)
    l = length(idxs)
    mean = [0., 0.]
    dev = 0.
    for idx in idxs 
        @inbounds mean += [idx[1], idx[2]]
    end
    mean = mean ./ l
    for idx in idxs
        dev += norm([idx[1], idx[2]] - mean)
    end
    sqrt(dev) / l
end

function main()
    path = ARGS[1]
    size = path == "sample.txt" ? [11, 7] : [101, 103]
    map = zeros(Integer, reverse(size) ...)
    quandrants = calc_quadrants(size)
    c = zeros(Integer, 4)
    robots = Matrix{Int}(undef, 0, 4)
    for line in eachline(open(path))
        robots = vcat(robots, reshape(parse_line(line), 1, :))
    end
    for row in eachrow(robots)
        x = move(row[1:2], row[3:4], 100, size)
        q = get_quadrant(x, quandrants)
        if q > 0
            c[q] += 1
        end
        map[CartesianIndex(reverse(x).+1 ...)] += 1
    end
    println("Task 1: $(prod(c))")
    minstddev = nothing
    t = 0
    for i=1:10000
        map[:] .= 0
        for row in eachrow(robots)
            x = move(row[1:2], row[3:4], i, size)
            map[CartesianIndex(reverse(x).+1 ...)] += 1
        end
        d = stddev(map)
        if minstddev == nothing || d < minstddev
            t = i
            minstddev = d
        end
    end
    println("Task 2: $(t)")
    map[:] .= 0
    for row in eachrow(robots)
        x = move(row[1:2], row[3:4], t, size)
        q = get_quadrant(x, quandrants)
        map[CartesianIndex(reverse(x).+1 ...)] += 1
    end
    ppmap(map)
end

@time main()


function readfs(path)
    id = 0
    isfree = false
    data = strip(read(path, String))
    numbers = parse.(Int, collect(data))
    fs = Vector{Int}(undef, sum(numbers))
    i = 1
    for n in numbers
        fs[i:i+n-1] .= isfree ? -1 : id
        if !isfree
            id += 1
        end
        isfree = !isfree
        i += n
    end
    return fs
end

function defrag!(fs)
    i, j = 1, length(fs)
    while i < j
        if fs[i] != -1
            i += 1
            continue
        end
        if fs[j] == -1
            j -= 1
            continue
        end
        fs[i], fs[j] = fs[j], fs[i]
    end
end

function sdefrag!(fs)
    for f in fs[end]:-1:0
        fb, fe = findfirst(x->x==f, fs), findlast(x->x==f, fs)
        fl = fe - fb + 1
        for x in 1:fb-fl
            if all(fs[x:x+fl-1] .== -1)
                fs[x:x+fl-1] = fs[fb:fe]
                fs[fb:fe] .= -1
                break
            end
        end
    end
    f = fs[end]
end

function checksum(fs)
  blocks = [b != -1 ? b : 0 for b in fs]
  sum((eachindex(blocks).-1) .* blocks)
end

function main()
    fs = readfs(ARGS[1])
    fs2 = copy(fs)
    defrag!(fs)
    println("Task 1: $(checksum(fs))")
    sdefrag!(fs2)
    println("Task 1: $(checksum(fs2))")
end

@time main()

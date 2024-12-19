function main()
    fh = open(ARGS[1])
    patterns = split(readline(fh), ", ")
    re = Regex("^(" * join(patterns, '|') * ")+\$")
    readline(fh)
    c = 0
    d = 0
    cache = Dict{String,Int}()
    while !eof(fh)
        line = readline(fh)
        if occursin(re, line)
            c += 1
            d += match_rec(line, patterns, cache)
        end
    end
    println("Task 1: $c")
    println("Task 2: $d")
end

function match_rec(str, patterns, cache)
    if str == ""
        return 1
    end
    rc = get(cache, str, nothing)
    if rc !== nothing
        return rc
    end
    r = 0
    for p in patterns
        if startswith(str, p)
            r += match_rec(str[length(p)+1:end], patterns, cache)
        end
    end
    cache[str] = r
    r
end

@time main()

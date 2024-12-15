const RE_BUTTON = r"^Button .\: X\+(\d+), Y\+(\d+)"
const RE_PRICE = r"^Prize\: X=(\d+), Y=(\d+)" #"

function parse_line(f, re)
    parse.(Int, match(re, readline(f)))
end

function calc_tokens(A, b, offset)
    b = b .+ offset
    x = round.(A\b, digits=4)
    if all(isinteger.(x))
        xi = convert.(Integer, x)
        return 3xi[1] + xi[2]
    end
    0
end

function main()
    f = open(ARGS[1])
    A = Matrix{Integer}(undef, 2, 2)
    b = Vector{Integer}(undef, 2)
    tokens1 = 0
    tokens2 = 0
    while !eof(f)
        A[:, 1] = parse_line(f, RE_BUTTON)
        A[:, 2] = parse_line(f, RE_BUTTON)
        b[:] = parse_line(f, RE_PRICE)
        readline(f)
        tokens1 += calc_tokens(A, b, 0)
        tokens2 += calc_tokens(A, b, 10000000000000)
    end
    println("Task 1: $(tokens1)")
    println("Task 1: $(tokens2)")
end

@time main()

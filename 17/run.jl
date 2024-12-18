mutable struct Machine
    pc::UInt
    program::Vector{UInt8}
    a::UInt
    b::UInt
    c::UInt
    out:: Vector{UInt8}
end

function read_input(path)
    fh = open(path)
    a = parse(UInt, split(readline(fh), ": ")[2])
    b = parse(UInt, split(readline(fh), ": ")[2])
    c = parse(UInt, split(readline(fh), ": ")[2])
    readline(fh)
    program = parse.(UInt, split(split(readline(fh), ": ")[2], ','))
    Machine(0, program, a, b, c, Vector{UInt8}())
end

function ico(ma::Machine, o::UInt8)::UInt
    if o <= 3
        return o
    end
    if o == 4
        return ma.a
    end
    if o == 5
        return ma.b
    end
    if o == 6
        return ma.c
    end
    throw(DomainError(o, "Illegal operand"))
end

function dv(a::UInt, b::UInt)::UInt
    div(a, 2^b)
end

function adv(ma::Machine, o::UInt8)
    ma.a = dv(ma.a, ico(ma, o))
    ma.pc += 2
end

function bxl(ma::Machine, o::UInt8)
    ma.b = xor(ma.b, o)
    ma.pc += 2
end

function bst(ma::Machine, o::UInt8)
    ma.b = mod(ico(ma, o), 8)
    ma.pc += 2
end

function jnz(ma::Machine, o::UInt8)
    if ma.a == 0
        ma.pc += 2
    else
        ma.pc = o
    end
end

function bxc(ma::Machine, o::UInt8)
    ma.b = xor(ma.b, ma.c)
    ma.pc += 2
end

function out(ma::Machine, o::UInt8)
    push!(ma.out, mod(ico(ma, o), 8))
    ma.pc += 2
end

function bdv(ma::Machine, o::UInt8)
    ma.b = dv(ma.a, ico(ma, o))
    ma.pc += 2
end

function cdv(ma::Machine, o::UInt8)
    ma.c = dv(ma.a, ico(ma, o))
    ma.pc += 2
end

const OPS = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]

function loop(ma)
    l = length(ma.program)
    while ma.pc < l
        opcode = ma.program[ma.pc+1]
        op = OPS[opcode+1]
        op(ma, ma.program[ma.pc+2])
    end
end

function run_a(ma, a)
    ma.pc = 0
    ma.a = a
    ma.b = 0
    ma.c = 0
    empty!(ma.out)
    loop(ma)
end

function backsolve(ma, out)
    if length(out) == 0
        return 0
    end
    res = Vector{Int}()
    for ah in backsolve(ma, out[2:end])
        for al=0:7
            a = 8ah + al
            run_a(ma, a)
            if ma.out == out
                push!(res, a)
            end
        end
    end
    res
end

function main()
    ma = read_input(ARGS[1])
    loop(ma)
    println("Task 1: ", join(string.(ma.out), ','))
    a = minimum(backsolve(ma, ma.program))
    println("Task 2: ", a)
    println(join(string.(ma.out), ','))
end

@time main()


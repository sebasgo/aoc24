function tryop(acc, operands, target, ops)
    if isempty(operands)
        return acc == target
    end
    for op in ops
        if tryop(op(acc, operands[1]), operands[2:end], target, ops)
            return true
        end
    end
    return false
end

function concat(x, y)
    10^Int(ceil(log10(y+1))) * x + y
end

function main()
    sum1 = 0
    sum2 = 0
    for line in eachline(open(ARGS[1]))
        target_s, operands_s = split(line, ": ")
        target = parse(Int, target_s)
        operands = parse.(Int, split(operands_s, ' '))
        sum1 += tryop(operands[1], operands[2:end], target, [+, *]) ? target : 0
        sum2 += tryop(operands[1], operands[2:end], target, [+, *, concat]) ? target : 0
    end
    println("Task 1: $(sum1)")
    println("Task 2: $(sum2)")
end

@time main()

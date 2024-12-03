function read_input()
    return read("input.txt", String)
end

function task1(input)
    pattern = r"mul\((\d+),(\d+)\)"
    products = map(eachmatch(pattern, input)) do m
       x, y = parse.(Int, m.captures)
       x * y
    end
    println("Task 1: $(sum(products))")
end

function task2(input)
    pattern = r"(mul\((\d+),(\d+)\)|do\(\)|don\'t\(\))"
    enable = true
    sum = 0
    for m in eachmatch(pattern, input)
        op, x, y = m.captures
        if startswith(op, "mul(")
            if enable
                x, y = parse.(Int, (x, y))
                sum += x * y
            end
        elseif startswith(op, "don't(")
            enable = false
        elseif startswith(op, "do(")
            enable = true
        end
    end
    println("Task 1: $(sum)")
end

function main()
    input = read_input()
    task1(input)
    task2(input)
end

main()

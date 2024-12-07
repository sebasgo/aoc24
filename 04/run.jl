function readinput()
    lines = Vector{String}()

    for line in eachline(open("input.txt"))
        append!(lines, [line])
       # append!(chars, collect(line))
    end
    chars = Matrix{Char}(undef, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        chars[i, :] = collect(line)
    end
    chars
end

function readfour(chars, x, y, dx, dy)
    str = ""
    for _ in 1:4
        str = str * chars[y, x]
        x += dx
        y += dy
        if x < 1 || x > size(chars, 1) || y < 1 || y > size(chars, 2)
            break
        end
    end
    str
end

function countxmas(chars)
    c = 0
    for x = 1:size(chars, 1)
        for y = 1:size(chars, 2)
            for dx = -1:1
                for dy = -1:1
                    if readfour(chars, x, y, dx, dy) == "XMAS"
                        c += 1
                    end
                end
            end
        end
    end
    c
end

function read3c(chars, x, y, dx, dy)
    String([chars[x + i*dx, y + i*dy] for i in -1:1])
end

function ismas(chars, x, y)
    for dl = -1:2:1
        l = read3c(chars, x, y, dl, dl)
        for dr = -1:2:1
            r = read3c(chars, x, y, dr, -dr)
            if l == r == "MAS"
                return true
            end
        end
    end
    false
end

function countmas(chars)
    c = 0
    for x = 2:size(chars, 1)-1
        for y = 2:size(chars, 2)-1
            if ismas(chars, x, y)
                c += 1
            end
        end
    end
    c
end


function main()
    input = readinput()
    println("Task 1: $(countxmas(input))")
    ismas(input, 2 , 2)
    println("Task 2: $(countmas(input))")
end 

@time main()
@time main()


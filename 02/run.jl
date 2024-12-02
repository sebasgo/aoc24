function issafe(row)
    diff = row[2:end] - row[1:end-1]
    absdiff = abs.(diff)
    return (all(diff .> 0) || all(diff .< 0)) && all(absdiff .> 0) && all(absdiff .< 4)
end

function issafer(row)
    for i in 1:length(row)
        if issafe(row[1:end .!== i])
            return true
        end
    end
    return false
end

safe = 0
safer = 0

for line in eachline("input.txt")
    global safe
    global safer
    row = parse.(Int, split(line))
    if issafe(row)
        safe += 1
    end
    if issafer(row)
        safer += 1
    end
end

println("Part One")
display(safe)
println("Part Two")
display(safer)

Rules = Dict{Int, Vector{Int}}

parse_rule(line) = parse.(Int, split(line, "|"))

function addrule!(rules, line)
    k, v = parse.(Int, split(line, "|"))
    vs = get!(rules, k, Vector{Int}())
    append!(vs, v)
end

readupdate(line) = parse.(Int, split(line, ","))

function checkupdate(update, rules)
    for (i, page) in enumerate(update)
        prev_pages = update[begin:i-1]
        # println("$(page): $(prev_pages)")
        if !checkpage(page, prev_pages, rules)
            # println("bad")
            return false
        end
    end
    return true
end

function checkpage(page, prev_pages, rules)
    page_rule = get(rules, page, Vector{Int}())
    length(intersect(prev_pages, page_rule)) == 0
end

midpage(update) = update[div(length(update), 2) + 1]

function fixupdate(update, rules)
    for (i, page) in enumerate(update)
        prev_pages = update[begin:i-1]
        while !checkpage(page, prev_pages, rules)
            update[i-1], update[i] = update[i], update[i-1]
            i -= 1
            prev_pages = update[begin:i-1]
        end
    end
    update
end

function enforce_rules()
    rules = Rules()
    collect_rules = true
    pagesum = 0
    corrected_pagesum = 0
    for line in eachline(open("input.txt"))
        if line == ""
            collect_rules = false
            # display(rules)
            continue
        end
        if collect_rules
            addrule!(rules, line)
        else
            update = readupdate(line)
            # display(update)
            if checkupdate(update, rules)
                pagesum += midpage(update)
            else
                # println("broken: $(update)")
                update = fixupdate(update, rules)
                corrected_pagesum += midpage(update)
                # println("fixed: $(update)")
            end
        end
    end
    println("Task 1: $(pagesum)")
    println("Task 2: $(corrected_pagesum)")
end

function main()
    enforce_rules()
end

@time main()
@time main()

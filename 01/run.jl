using DelimitedFiles

inp = readdlm("input.txt", Int)

println("Part One")

l = inp[:, 1]
r = inp[:, 2]
a = sum(abs.(sort(l) - sort(r)))

display(a)

println("Part Two")

res = 0
for i = 1:length(l)
    global res
    v = l[i]
    res += v * sum(r .== v)
end

display(res)

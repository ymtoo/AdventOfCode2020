using DelimitedFiles

function isanysumto(xs, a)
    ys = sort(xs)
    n = length(ys)
    for i ∈ 1:n
        y = ys[i]
        for j ∈ n:-1:1
            if i != j
                summ = y + ys[j]
                summ < a && break
                summ == a && return true
            end
            i >= j && return false
        end
    end
    false
end

function getfirstvalidnumber(xs, n)
    for j ∈ n+1:length(xs)
        !(@views isanysumto(xs[j-n:j-1], xs[j])) && return xs[j]
    end
end

function findcontiguousset(xs, summ)
    for i ∈ 2:length(xs)
        for j ∈ 1:length(xs)-i+1
            xs1 = @view sum(xs[j:j+i-1])
            s = sum(xs1)
            s == summ && return maximum(xs1)+minimum(xs1)
            s > summ && break
        end
    end
    0
end

xs = vec(readdlm("data.csv", '\n', Int))

summ = getfirstvalidnumber(xs, 25) # 175.688 μs (485 allocations: 136.14 KiB)
findcontiguousset(xs, summ) # 130.257 μs (1 allocation: 16 bytes)
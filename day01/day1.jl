using DelimitedFiles

function findsumto2020(xs)
    sort!(xs)
    n = length(xs)
    y = Int[]
    for i ∈ 1:n
        x = xs[i]
        for j ∈ n:-1:1
            if i != j
                summ = x + xs[j]
                summ < 2020 && break
                summ == 2020 && push!(y, x * xs[j])
            end
            i >= j && return y
        end
    end
    return y
end

xs = vec(readdlm("data.csv", 'r', Int))
y = findsumto2020(xs)

@btime findsumto2020(xs)

#63 1 2

function findtriplesumto2020(xs)
    sort!(xs)
    n = length(xs)
    y = Int[]
    for i ∈ 1:n
        x1 = xs[i]
        for ii ∈ 1:n
            ii > i && break
            x2 = xs[ii]
            x1 + x2 >= 2020 && break
            for j ∈ n:-1:1
                if ii != j
                    summ = x1 + x2 + xs[j]
                    summ < 2020 && break
                    summ == 2020 && push!(y, x1 *  x2 * xs[j])
                end
            end
            max(i, ii) >= j && return y
        end
    end
    return y
end

y = findtriplesumto2020(xs)

@btime findtriplesumto2020(xs)

for i ∈ 1:10
    for j ∈ 1:20
        for k ∈ 1:30
            i == k && (println("$i $j $k");break)
        end
    end
end
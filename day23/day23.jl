using CircularArrays

function simulate1(xsori, n)
    xs = CircularArray(copy(xsori))
    m = length(xs)
    minvalue, maxvalue = 1, m
    for i ∈ 1:n
        pickup = xs[i+1:i+3]
        dest = xs[i] - 1
        while true
            dest < minvalue && (dest = maxvalue)
            dest ∉ pickup && break
            dest -= 1
        end
        im = i ÷ m
        index = findfirst(xs .== dest)
        indices = index < (i % m) ? (i+4:(im + 1) * m + index) : (i+4:im * m + index)
        nindices = length(indices)
        @views xs[i+1:i+nindices] .= xs[indices]
        @views xs[i+nindices+1:i+nindices+3] .= pickup
    end
    xs
end

function getorder(data, n)
    xs = simulate1(data, n)
    oneindex = findfirst(xs .== 1)
    s = ""
    for i ∈ 1:8
        s *= string(xs[oneindex+i])
    end
    println(s)
end

"""
Linked list.
"""
function simulate2(xsori, n)
    xs = copy(xsori)
    m = length(xs)
    d = Dict([number => xs[1 + (i % m)] for (i, number) ∈ enumerate(xs)])
    current = xs[1]
    maxvalue = maximum(xs)
    for i ∈ 1:n
        c1 = d[current]
        c2 = d[c1]
        c3 = d[c2]
        nxt = d[c3]
        pickup = [c1, c2, c3]
        dest = current - 1
        while true
            dest < 1 && (dest = maxvalue)
            dest ∉ pickup && break
            dest -= 1
        end
        d[current] = nxt
        d[c3] = d[dest]
        d[dest] = c1
        current = nxt
    end
    current = 1
    cups = Int[]
    for i ∈ 1:n
        push!(cups, current)
        current = d[current]
    end
    cups
end
getproduct(data, n) = simulate2(data, n) |> x -> x[2] * x[3]

test = [3,8,9,1,2,5,4,6,7]
data = [3,6,8,1,9,5,7,4,2]
data1 = vcat(data,collect(10:1000000))

getorder(data, 100) # 156.252 μs (1943 allocations: 82.28 KiB)
getproduct(data1, 10000000) # 7.341 s (10000083 allocations: 1.26 GiB)
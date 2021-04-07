using Transducers

function multiply1(ls) 
    earliesttime = parse(Int, first(ls))
    ids = last(ls) |> 
          x -> split(x, ',') |> 
          Filter(a -> a != "x") |> 
          Map(x -> parse(Int, x)) |> collect
    mt = earliesttime .% ids
    any(mt .== 0) ? minimum(mt) : findmin(ids .- mt) |> x -> x[1] * ids[x[2]]
end

"""
Chinese Remainder Theorem
"""
function findsmallest(ls)
    earliesttime = parse(Int, first(ls))

    idstmp = split(last(ls), ',')
    indices = idstmp .!= "x"
    ids = parse.(Int, idstmp[indices]) 
    mt = collect(0:length(idstmp)-1)[indices]
    a = ids - mt
    N = prod(ids)
    y = N .÷ ids
    s = invmod.(y, ids)
    sum(a .* s .* y) % N
end
    
ls = readlines("data.csv")

multiply1(ls) # 6.878 μs (176 allocations: 15.80 KiB)
findsmallest(ls) # 7.326 μs (178 allocations: 17.08 KiB)
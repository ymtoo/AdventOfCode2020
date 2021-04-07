using Pipe: @pipe
using DelimitedFiles

using Combinatorics
using Transducers

multiplydifferences(xs) = @pipe sort(xs) |> 
                                pushfirst!(_, 0) |>
                                push!(_, last(_)+3) |>
                                diff(_) |>
                                count(==(3), _) * count(==(1), _)

function getsplitindices(xssort)
    dxs3 = findall(diff(xssort) .== 3)
    vs = UnitRange{Int}[]
    isempty(dxs3) && return push!(vs, 1:length(xssort))
    startindex = 1
    for index ∈ dxs3
        if index != startindex
            push!(vs, startindex:index)
        end
        startindex = index + 1
    end
    startindex < length(xssort) && push!(vs, startindex:length(xssort))
    vs
end

removediff(a, b) = [a1 for a1 in a if a1 ∉ b]

function _findnumberofcombinations(x)
    x1 = @view(x[2:end-1])
    cnt = 1 + length(x1)
    for i ∈ length(x1):-1:2
        for y ∈ combinations(x1, i)
            if !(@pipe removediff(x, y) |> diff(_) |> any(_ .> 3)) 
                cnt += 1
            end
        end
    end
    cnt
end

function findnumberofcombinations(xs)
    xssort = sort(xs)
    pushfirst!(xssort, 0)
    vs = getsplitindices(xssort)
    vs |> 
    Filter(x -> length(x) >= (3)) |> 
    Map(v -> @view(xssort[v])) |> 
    Map(x -> _findnumberofcombinations(x)) |>
    prod
end

xs = vec(readdlm("data.csv", '\n', Int))

multiplydifferences(xs) # 2.697 μs (11 allocations: 12.98 KiB)
findnumberofcombinations(xs) # 12.040 μs (372 allocations: 30.83 KiB)
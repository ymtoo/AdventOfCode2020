using DelimitedFiles
using Hungarian
using Pipe: @pipe

removeor_split(s) = @pipe replace(s, " or "=>" ") |> 
                          split(_, " ") |> 
                          map(x -> split(x, "-"), _) |>
                          map(x -> [parse(Int, x[1]), parse(Int, x[2])], _)

function gettickets(s, title)
    tickets = @pipe s |>
                    replace(_, title => "") |>
                    split(_, '\n') |>
                    map(x -> parse.(Int, split(x, ',')), _)
end

function extract(datastrings)
    d = @pipe datastrings[1] |> 
        split(_, "\n") |> 
        map(x -> split(x, ": "), _) |>
        map(x -> (x[1], removeor_split(x[2])), _) |>
        Dict
    yourticket = first(gettickets(datastrings[2], "your ticket:\n"))
    nearbytickets = gettickets(datastrings[3], "nearby tickets:\n") 
    d, yourticket, nearbytickets
end

isin(x, lb, ub) = x >= lb && x <= ub
function anyisinall(x, d)
    for (key, d1) ∈ d
        for d2 ∈ d1
            isin(x, d2[1], d2[2]) && return true
        end
    end
    false
end 

function geterrorrate1(datastrings)
    d, yourticket, nearbytickets = extract(datastrings)
    acc = 0
    for nearbyticket ∈ nearbytickets
        for x ∈ nearbyticket
            !anyisinall(x, d) && (acc += x)
        end
    end
    acc
end

function getvotes(x, d)
    ks = keys(d)
    bs = zeros(Bool, length(ks))
    for (i, (key, d1)) ∈ enumerate(d)
        for d2 ∈ d1
            if isin(x, d2[1], d2[2])
                bs[i] += 1
                break
            end
        end
    end
    bs
end

function prodstartwith(datastrings, s)
    d, yourticket, nearbytickets = extract(datastrings)
    V = zeros(Int, length(d), length(d))
    for nearbyticket ∈ nearbytickets
        for (i, x) ∈ enumerate(nearbyticket)
            V[i,:] += getvotes(x, d)
        end
    end
    assignment, cost = hungarian(-V)
    reassign = Array{Int}(undef, length(assignment))
    for (i, a) in enumerate(assignment)
        reassign[a] = i
    end
    x = yourticket[reassign]
    indices = findall(startswith.(keys(d), s))
    isempty(indices) ? 0 : x[indices] |> prod
end

datastrings = open("data.txt") do f
    @pipe read(f, String) |> split(_, "\n\n")
end

geterrorrate1(datastrings) # 702.948 μs (7136 allocations: 682.00 KiB)
prodstartwith(datastrings, "departure") # 1.982 ms (21294 allocations: 3.34 MiB)
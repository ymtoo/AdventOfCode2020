using Pipe: @pipe

function _play2(p1ori, p2ori)
    p1, p2 = copy(p1ori), copy(p2ori)
    prevs = Vector{Int}[]
    while true
        p1 ∈ prevs && return (1, p1)
        push!(prevs, copy(p1))
        as = popfirst!(p1), popfirst!(p2)
        a1, a2 = as
        if (a1 ≤ length(p1)) && (a2 ≤ length(p2))
            winner, _ = _play2(p1[1:a1], p2[1:a2])
            winner == 1 ? append!(p1, [a1, a2]) : append!(p2, [a2, a1])
        elseif a1 > a2 
            append!(p1, [a1, a2])
        elseif a1 < a2 
            append!(p2, [a2, a1])
        end
        isempty(p1) && return (2, p2)
        isempty(p2) && return (1, p1)
    end
end
play2(p1, p2) = @pipe _play2(p1, p2) |> sum(_[2] .* (length(_[2]):-1:1))

function play1(p1ori, p2ori)
    p1, p2 = copy(p1ori), copy(p2ori)
    while true
        a1, a2 = popfirst!(p1), popfirst!(p2)
        if a1 > a2 
            append!(p1, [a1, a2])
        elseif a1 < a2 
            append!(p2, [a2, a1])
        end
        isempty(p1) && return sum(p2 .* (length(p2):-1:1))
        isempty(p2) && return sum(p1 .* (length(p1):-1:1))
    end
end



p1, p2 = open("data.txt") do f
    p1tmp, p2tmp = @pipe read(f, String) |> split(_, "\n\n")
    p1 = replace(p1tmp, "Player 1:\n"=>"")
    p2 = replace(p2tmp, "Player 2:\n"=>"")
    (@pipe split(p1, "\n") |> parse.(Int, _)), (@pipe split(p2, "\n") |> parse.(Int, _))
end

play1(p1, p2) # 14.364 μs (326 allocations: 34.84 KiB)
play2(p1, p2) # 368.882 ms (2023732 allocations: 304.75 MiB)
using Pipe: @pipe

function initializeactive(datastrings, args...)
    cs = NTuple{2+length(args),Int}[]
    for (y, datastring) ∈ enumerate(datastrings)
        for (x, datastring1) ∈ enumerate(datastring)
            datastring1 == '#' && push!(cs, (x-1, y-1, args...))
        end
    end
    cs
end
initializeactive(datastrings) = initializeactive(datastrings, 0)

getneigborranges(vs) = range.(vs .- 1, vs .+ 1; step=1)

function getactiveneighbors(vs, cs)
    cnt = 0
    for vs1 ∈ Iterators.product(getneigborranges(vs)...)
        vs1 ∈ cs && (vs1 != vs) && (cnt += 1)
        cnt > 3 && break
    end
    cnt
end

function getactives!(cs, ncycles)
    for i ∈ 1:ncycles
        inactiveindices = Int[]
        nowactives = NTuple{length(cs[1]),Int}[]
        cartersianindices = NTuple{length(cs[1]),Int}[]
        for c ∈ cs
            for c1 ∈ Iterators.product(getneigborranges(c)...)
                if c1 ∉ cartersianindices
                    push!(cartersianindices, c1)
                    n = getactiveneighbors(c1, cs)
                    if c1 ∈ cs # active
                        if n ∉ (2, 3) 
                            index = findfirst(cs .== [c1])
                            index ∉ inactiveindices && push!(inactiveindices, index)
                        end
                    elseif n == 3 && (c1 ∉ nowactives) # inactive
                        push!(nowactives, c1)
                    end
                end
            end
        end
        deleteat!(cs, sort(inactiveindices))
        append!(cs, nowactives)
    end
    cs
end
getnumberactives1(datastrings, ncycles) = @pipe initializeactive(datastrings) |>
                                                getactives!(_, ncycles) |> 
                                                length(_)

getnumberactives2(datastrings, ncycles) = @pipe initializeactive(datastrings, 0, 0) |>
                                                getactives!(_, ncycles) |> 
                                                length(_)

datastrings = open("data.txt") do f
    @pipe read(f, String) |> split(_, "\n")
end

getnumberactives1(datastrings, 6) # 22.176 ms (2164 allocations: 1.63 MiB)
getnumberactives2(datastrings, 6) # 6.849 s (20697 allocations: 28.65 MiB)
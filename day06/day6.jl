using Pipe:@pipe

function countyes1(xs::Vector{T}) where {T<:AbstractString} 
    map(x -> length(unique(replace(x, "\n"=>""))), xs) |> sum
end

countyesingroup(ys::Vector{T}) where {T<:AbstractString} = length(intersect(ys...))
function countyes2(xs::Vector{T}) where {T<:AbstractString} 
    @pipe map(x->split(x, "\n"), xs) |> 
    map(x->countyesingroup(x), _) |> 
    sum
end

datastrings = open("data.csv") do f
    @pipe read(f, String) |> 
    split(_, "\n\n")
end

countyes1(datastrings) # 509.112 μs (6786 allocations: 604.84 KiB)
countyes2(datastrings) # using Pipe: @pipe
using Transducers

function countyes1(xs::Vector{T}) where {T<:AbstractString} 
    xs |> Map(x -> length(unique(replace(x, "\n"=>"")))) |> sum
end

countyesingroup(ys::Vector{T}) where {T<:AbstractString} = length(intersect(ys...))
function countyes2(xs::Vector{T}) where {T<:AbstractString} 
    xs |> Map(x->split(x, "\n")) |> 
    Map(x->countyesingroup(x)) |> 
    sum
end

datastrings = open("data.csv") do f
    @pipe read(f, String) |> 
    split(_, "\n\n")
end

countyes1(datastrings) # 509.112 μs (6786 allocations: 604.84 KiB)
countyes2(datastrings) # 1.294 ms (16423 allocations: 1.35 MiB)
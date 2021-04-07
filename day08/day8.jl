using Pipe: @pipe 

function getinstructions(xs::Vector{T}) where {T<:AbstractString}
    ys = Tuple{String,Int}[]
    for x ∈ xs
        x1, x2 = split(x, " ")
        push!(ys, (x1, parse(Int, x2)))
    end
    ys
end

acc(y, a, i) = (a += y[2]), (i += 1)
jmp(y, a, i) = a, (i += y[2])
nop(y, a, i) = a, (i += 1)

function getacc(ys::Vector{Tuple{ST,IT}}) where {ST<:AbstractString,IT<:Integer}
    checks = Int[]
    a = 0
    i = 1
    while true
        i ∉ checks ? push!(checks, i) : return (a, checks)
        f = getfield(Main, Symbol(ys[i][1]))
        a, i = f(ys[i], a, i)
        i > length(ys) && return (a, checks)
    end
end
getacc1(datastrings) = datastrings |> getinstructions |> getacc |> first

function changeop(x::Tuple{ST,IT}) where {ST<:AbstractString,IT<:Integer} 
    if x[1] == "jmp" 
        "nop", x[2]
    elseif x[1] == "nop"
        "jmp", x[2]
    else
        x
    end
end

function fixinstructions(ys::Vector{Tuple{ST,IT}}) where {ST<:AbstractString,IT<:Integer}
    a, checks = getacc(ys)
    for check ∈ reverse(checks)
        ysfix = copy(ys)
        ysfix[check] = changeop(ysfix[check])
        atmp, checkstmp = getacc(ysfix)
        last(checkstmp) == length(ys) && return ysfix
    end
end
getacc2(datastrings) = datastrings |> getinstructions |> fixinstructions |> getacc |> first

datastrings = open("data.csv") do f
    @pipe read(f, String) |> 
    split(_, "\n")
end

getacc1(datastrings) # 285.488 μs (3843 allocations: 249.97 KiB)
getacc2(datastrings) # 8.479 ms (93643 allocations: 3.63 MiB)
using Pipe: @pipe

function initializerules(x)
    d = Dict{String,Vector{String}}()
    for x1 ∈ x
        s  = split(x1, ": ")
        value = @pipe (occursin(" | ", s[2]) ? split(s[2], " | ") : [s[2]])
        d[s[1]] = value
    end
    d
end

function productstrings(as::Vector{String}, bs::Vector{String})
    s = String[]
    for a ∈ as
        for b ∈ bs
            push!(s, a * " " * b)
        end
    end
    s
end
productstrings(as::String,bs::Vector{String}) = isempty(as) ? bs : (as .* " " .* bs)
productstrings(as::Vector{String},bs::String) = isempty(bs) ? as : (as .* " " .* bs)
productstrings(as::String,bs::String) = isempty(as) ? bs : (as * " " * bs)

function reviserules(d, values)
    newvalues = String[]
    for xs ∈ values
        a = ""
        for x ∈ split.(xs, " ")
            a1 = string(x) ∉ ["a","b"] ? d[string(x)] : string(x) 
            a = productstrings(a, a1)
        end
        a isa Vector{String} ? append!(newvalues, a) : push!(newvalues, a)
    end
    newvalues
end

function getrules(d, values)
    while true
        newvalues = reviserules(d, values)
        values = newvalues
        if !any(occursin.(r"\d", newvalues)) 
            break
        end
    end
    values
end

function countvalid1(data)
    d = initializerules(data[1]) 
    values = @pipe getrules(d, d["0"]) |> map(x -> replace(x, " "=>""), _)
    cnt = 0
    for message ∈ data[2]
        message ∈ values && (cnt += 1)
    end
    cnt
end

function countvalid2(data)
    d = initializerules(data[1])
    d["8"] = ["42","42 8"] # ["42","42 42","42 42 42","42 42 42 42","42 42 42 42 42",...]
    d["11"] = ["42 31","42 11 31"] # ["42 31","42 42 31 31","42 42 42 31 31 31",...]

    ml = maximum(length.(data[2]))

    rules42 = @pipe getrules(d, d["42"]) |> map(x -> replace(x, " "=>""), _)
    rules31 = @pipe getrules(d, d["31"]) |> map(x -> replace(x, " "=>""), _)

    rules = productstrings(["42",
                            "42 42",
                            "42 42 42",
                            "42 42 42 42",
                            "42 42 42 42 42",
                            "42 42 42 42 42 42", 
                            "42 42 42 42 42 42 42",
                            "42 42 42 42 42 42 42 42",
                            "42 42 42 42 42 42 42 42 42",
                            "42 42 42 42 42 42 42 42 42 42"], 
                    ["42 31",
                        "42 42 31 31", 
                        "42 42 42 31 31 31",
                        "42 42 42 42 31 31 31 31",
                        "42 42 42 42 42 31 31 31 31 31",
                        "42 42 42 42 42 42 31 31 31 31 31 31"])

    l = length(rules42[1])
    cnt = 0
    for d2 ∈ data[2]
        a = ""
        for i ∈ 1:l:length(d2)
            x = @views d2[i:i+l-1]
            if x ∈ rules42 
                a = isempty(a) ? "42" : a * " 42"
            elseif x ∈ rules31
                a = isempty(a) ? "31" : a * " 31"
            end
        end
        a ∈ rules && (cnt += 1)
    end
    cnt
end

data = open("data.txt") do f
    @pipe read(f, String) |> replace(_, "\"" => "") |> split(_, "\n\n") |> split.(_, "\n")
end

countvalid1(data)
countvalid2(data)
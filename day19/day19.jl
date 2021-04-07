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

function reviserules!(d)
    for i = 1:5
        for (key, values) ∈ d
            if any(occursin.(r"[1-9]", values)) 
                newvalues = String[]
                for value ∈ values
                    a = ""
                    for v1 ∈ split(value, " ")
                        a1 = string(v1) ∉ ["a","b"] ? d[string(v1)] : string(v1)
                        a = productstrings(a, a1)
                    end
                    a isa Vector{String} ? append!(newvalues, a) : push!(newvalues, a)
                end
                println(newvalues)
                d[key] = newvalues
            end
        end
        !any(occursin.(r"[1-9]", d["0"])) && break
    end
    [d[key]=replace.(d[key], " "=> "") for (key, value) ∈ d]
    d
end

function countvalid(data)
    d = initializerules(data[1]) 
    reviserules!(d)
    l = length.(d["0"])[1]
    cnt = 0
    for message ∈ data[2]
        length(message) == l && (message ∈ d["0"]) && (cnt += 1)
    end
    cnt
end

data = open("test3.txt") do f
    @pipe read(f, String) |> replace(_, "\"" => "") |> split(_, "\n\n") |> split.(_, "\n")
end

d = initializerules(data[1]) 
reviserules!(d)
countvalid(data)

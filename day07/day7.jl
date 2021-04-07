using DelimitedFiles
using Pipe: @pipe

function findheadbags(rules, childbags)
    headbags = String[]
    for childbag ∈ childbags
        for rule ∈ rules
            if !isnothing(findfirst(childbag, rule))
                headbag = rule[1:first(findfirst(" bags", rule))-1]
                childbag != headbag && push!(headbags, headbag)
            end
        end
    end
    headbags
end

function findallheadbags(rules, childbags)
    allheadbags = String[]
    l = length(allheadbags)
    while true 
        allheadbagstmp = findheadbags(rules, childbags)
        union!(allheadbags, allheadbagstmp)
        if length(allheadbags) > l
            l = length(allheadbags)
            childbags = allheadbagstmp
        else
            break
        end
    end
    allheadbags
end
findnumberofheadbags(rules, childbags) = length(findallheadbags(rules, childbags))

function findchildbags(rules, headbag)
    rule = first(rules[headbag .== first.(split.(rules, " bags"))])
    x = @pipe split(rule, "contain ") |> 
            last |> 
            split(_, ", ") |> 
            replace.(_, " bags"=>"") |> 
            replace.(_, " bag"=>"") |> 
            split.(_, " "; limit=2) 
    first(x) != ["no","other"] ? (last.(x), parse.(Int, first.(x))) : ([SubString("nothing"),], [0,])
end

function findnumberofchildbags(rules, bags)
    summ = Int[]
    allchildbags = copy(bags)
    vs = [1]
    while true
        xstmp = AbstractString[]
        vstmp = Int[]
        summtmp = Int[]
        for (bag, v) ∈ zip(bags, vs)
            childbags, numberchildbags = findchildbags(rules, bag)
            if childbags != ["nothing"]
                append!(xstmp, childbags)
                append!(vstmp, numberchildbags .* v)
                append!(summtmp, numberchildbags .* v)
            end
        end
        isempty(summtmp) && break
        bags = xstmp
        vs = vstmp
        append!(summ, summtmp)
        append!(allchildbags, bags)
    end
    sum(summ)
end

rules = open("data.csv") do f
    @pipe read(f, String) |> 
    split(_, "\n") |> map(x -> replace(x, "." => ""), _)
end
bags = ["shiny gold"]

findnumberofheadbags(rules, bags) # 25.953 ms (584064 allocations: 35.70 MiB)
findnumberofchildbags(rules, bags) # 39.112 ms (985284 allocations: 71.03 MiB)
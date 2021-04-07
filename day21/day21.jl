using Pipe: @pipe

function extractdata(datastrings)
    ingredients = Vector{String}[]
    allergens = Vector{String}[]
    allallergens = String[]
    for datastring ∈ datastrings
        a = split(datastring, " (")
        push!(ingredients, split(first(a), " "))
        allergen = @pipe replace(last(a), "contains " => "") |> 
                         replace(_, ")" => "") |> 
                         split(_, ", ")
        push!(allergens, allergen)
        [push!(allallergens, x) for x ∈ allergen if x ∉ allallergens]
    end 
    ingredients, allergens, allallergens
end

function getingredients(datastrings)
    ingredients, allergens, allallergens = extractdata(datastrings)
    ais = Dict{String,String}()
    for i = 1:100
        rmallallergens = String[]
        for allallergen ∈ allallergens
            vs = [i for (i, allergen) ∈ enumerate(allergens) if allallergen ∈ allergen]
            a = intersect(ingredients[vs]...)
            if length(a) == 1
                filter!.(x -> x != allallergen, allergens) 
                ingredient1 = first(a)
                ais[allallergen] = ingredient1
                #push!(ingredientlist, ingredient1)
                filter!.(x -> x != ingredient1, ingredients)
                push!(rmallallergens, allallergen)
            end
        end
        filter!(x -> x ∉ rmallallergens, allallergens)
        length(allallergens) == 0 && break
    end
    ingredients, ais
end
countingredients(datastrings) = @pipe getingredients(datastrings) |> length.(_[1]) |> sum
function getdangerousingredients(datastrings)
    _, ais = getingredients(datastrings)
    s = ""
    for (key, value) ∈ sort(ais)
        s *= value * ","
    end
    s[1:end-1]
end

datastrings = readlines("data.txt")
countingredients(datastrings) # 938.337 μs (8432 allocations: 863.12 KiB)
getdangerousingredients(datastrings) # 959.663 μs (8461 allocations: 864.73 KiB)
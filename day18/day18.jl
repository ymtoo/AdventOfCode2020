using Transducers

∘(a::Int, b::Int) = a + b
⤉(a::Int, b::Int) = a + b
sumvalues(ds, sum1) = ds |> 
                   Map(s -> replace(s, "+" => sum1)) |>
                   Map(s -> Meta.parse(s)) |>
                   Map(x -> eval(x)) |>
                   sum

ds = readlines("data.txt")
sumvalues(ds, "∘") # 133.399 ms (40060 allocations: 2.52 MiB)
sumvalues(ds, "⤉") # 130.507 ms (38233 allocations: 2.40 MiB)
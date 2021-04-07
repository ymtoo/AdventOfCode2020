using DelimitedFiles
using Pipe: @pipe

# part #1
function countvalidpassword1(data)
    @pipe eachrow(data) |> map(x->(split(x[1], ('-', ' ')), lstrip(x[2])), _) |> map(x->length(findall(x[1][3], x[2]))∈parse(Int, x[1][1]):parse(Int, x[1][2]), _) |> sum
end

# part #2
function countvalidpassword2(data)
    @pipe eachrow(data) |> map(x->(split(x[1], ('-', ' ')), lstrip(x[2])), _) |> map(x->intersect(first.(findall(x[1][3], x[2])), [parse(Int, x[1][1]),parse(Int, x[1][2])]), _) |> count(x->length(x)==1, _)
end

data = readdlm("data.csv", ':', String)

countvalidpassword1(data)
countvalidpassword2(data)
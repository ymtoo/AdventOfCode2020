using DelimitedFiles
using Pipe: @pipe

data = readdlm("data.csv", String)

function _counttrees(data, right, down)
    n = length(data)
    m = length(data[1])
    i = 1
    j = 1
    count = 0
    while i < n
        i += down
        j += right
        j = mod(j-1, m) + 1
        data[i][j] == '#' && (count += 1)
    end
    count
end
counttrees1(data) = _counttrees(data, 3, 1)
counttrees2(data) = @pipe zip([1,3,5,7,1], [1,1,1,1,2]) |> map(x -> _counttrees(data, x[1], x[2]), _) |> prod

counttrees1(data) #3.011 μs (0 allocations: 0 bytes)
counttrees2(data) #13.586 μs (4 allocations: 400 bytes)
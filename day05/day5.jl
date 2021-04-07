using DelimitedFiles

halve(r::UnitRange) = first(r) + (last(r) - first(r)) ÷ 2
rangeForL(r::UnitRange) = first(r):halve(r)
rangeBorR(r::UnitRange) = halve(r)+1:last(r)

function getrc(xs::AbstractString)
    r = 0:2^length(xs)-1
    for x in xs
        r = x ∈ ['F','L']  ? r = rangeForL(r) : rangeBorR(r)
    end
    r[1]           
end

getseatid(row, column) = row * 8 + column
function getseatids(data::AbstractVector)
    seatids = Int[]
    for x ∈ data
        row, column = getrc(x[1:7]), findrc(x[8:end])
        push!(seatids, getseatid(row, column))
    end
    seatids
end

highestseatid(data) = maximum(getseatids(data))

function findmyseatid(data)
    seatids = sort(getseatids(data))
    seatids[findall(diff(seatids) .== 2)[1]] + 1  
end

data = vec(readdlm("data.csv", '\n', String))
highestseatid(data) # 256.672 μs (9671 allocations: 821.41 KiB)
findmyseatid(data) # 284.416 μs (9677 allocations: 838.78 KiB)


tests = ["BFFFBBFRRR","FFFBBBFRRR","BBFFBBFRLL"]
testrows = [70,14,102]
testcolumns = [7,7,4]
testseatids = [567,119,820]
for (x, testrow, testcolumn, testseatid) ∈ zip(tests, testrows, testcolumns, testseatids)
    println(x)
    row, column = findrc(x[1:7]), findrc(x[8:end])
    @assert row == testrow
    @assert column == testcolumn
    @assert getseatid(row, column) == testseatid
end
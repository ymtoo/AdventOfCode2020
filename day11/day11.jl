using PaddedViews

function createdata(ds)
    X = Matrix{Union{Nothing,Bool}}(undef, length(ds), length(first(ds)))
    for (i, d) ∈ enumerate(ds)
        for (j, d1) ∈ enumerate(d)
            d1 == 'L' && (X[i,j] = false)
            d1 == '#' && (X[i,j] = true)
        end
    end
    X
end

Base.:*(::Bool, ::Nothing) = nothing
Base.:*(x::Nothing, y::Bool) = Base.:*(y, x)

const kernel = [true true true
                true false true
                true true true]

function changeseat1(X, i, j)
    X1 = X[(i-1):(i+1),(j-1):(j+1)]
    seat = X1[2,2]
    n = count((X1 .* kernel) .== true)#countadjacentoccupancy1(X1)
    if seat === false && (n == 0)
        true
    elseif seat === true && (n >= 4)
        false
    else
        seat
    end
end

function getstableseats(ds, changeseat)
    X = createdata(ds)
    while true
        Xnew = copy(X)
        Xp = PaddedView(nothing, X, (0:size(X,1)+1, 0:size(X,2)+1))
        for i ∈ 1:size(X,1)
            for j ∈ 1:size(X,2)
                newseat = changeseat(Xp, i, j)
                if newseat != @view(X[i,j])
                    Xnew[i,j] = newseat
                end
            end
        end
        X == Xnew && break
        X = Xnew
    end
    X
end
countoccupancy1(ds) = getstableseats(ds, changeseat1) |> x -> count(x .== true)

upindex(i, j) = (CartesianIndex(x, j) for x ∈ i-1:-1:1)
upleftindex(i, j) = (CartesianIndex(x...) for x ∈ zip(i-1:-1:1, j-1:-1:1))
leftindex(i, j) = (CartesianIndex(i, x) for x ∈ j-1:-1:1)
downleftindex(i, j, iend) = (CartesianIndex(x...) for x ∈ zip(i+1:iend, j-1:-1:1))
downindex(i, j, iend) = (CartesianIndex(x, j) for x ∈ i+1:iend)
downrightindex(i, j, iend, jend) = (CartesianIndex(x...) for x ∈ zip(i+1:iend, j+1:jend))
rightindex(i, j, jend) = (CartesianIndex(i, x) for x ∈ j+1:jend)
uprightindex(i, j, jend) = (CartesianIndex(x...) for x ∈ zip(i-1:-1:1, j+1:jend))

function getfirstseat(X, f, args...) 
    g = f(args...) 
    x = nothing
    for g1 ∈ g
        x = X[g1]
        !isnothing(x) && break
    end 
    x
end

function countadjacentoccupancy(X, i, j)
    iend, jend = size(X)
    sum(Union{Nothing,Bool}[getfirstseat(X, upindex, i, j),
                            getfirstseat(X, upleftindex, i, j),
                            getfirstseat(X, leftindex, i, j),
                            getfirstseat(X, downleftindex, i, j, iend),
                            getfirstseat(X, downindex, i, j, iend),
                            getfirstseat(X, downrightindex, i, j, iend, jend),
                            getfirstseat(X, rightindex, i, j, jend),
                            getfirstseat(X, uprightindex, i, j, jend)] .== true)
end

function changeseat2(X, i, j)
    seat = X[i,j]
    n = countadjacentoccupancy(X.data, i, j)
    if seat === false && (n == 0)
        true
    elseif seat === true && (n >= 5)
        false
    else
        seat
    end
end
countoccupancy2(ds) = getstableseats(ds, changeseat2) |> x -> count(x .== true)

ds = readlines("data.csv")
countoccupancy1(ds) # 182.220 ms (2378934 allocations: 195.13 MiB)
countoccupancy2(ds) # 316.425 ms (2378934 allocations: 170.93 MiB)
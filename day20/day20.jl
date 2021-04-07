using Pipe: @pipe

function readtiles(datastrings)
    tiles = Dict{Int,Matrix{Bool}}()
    for datastring ∈ datastrings
        m = length(datastring[2:end])
        n = length(datastring[2])
        tile = trues(m, n)
        key = @pipe last(split(datastring[1], " ")) |> replace(_, ":"=>"") |> parse(Int, _)
        for (i, xs) ∈ enumerate(datastring[2:end])
            for (j, x) ∈ enumerate(xs)
                x == '.' && (tile[i,j] = false)
            end 
        end
        tiles[key] = tile
    end
    tiles
end

orientations = [identity,
                rotr90,
                rot180,
                rotl90,
                x -> reverse(rotr90(x); dims=1),
                x -> reverse(rotl90(x); dims=1), 
                x -> reverse(x; dims=1),
                x -> reverse(x; dims=2),
]

function matchup(x, y, orientations) 
    matches = map(f -> (@views x[1,:] == f(y)[end,:]), orientations)
    any(matches) ? orientations[matches] : nothing
end
function matchdown(x, y, orientations)
    matches = map(f -> (@views x[end,:] == f(y)[1,:]), orientations)
    any(matches) ? orientations[matches] : nothing
end
function matchleft(x, y, orientations)
    matches = map(f -> (@views x[:,1] == f(y)[:,end]), orientations)
    any(matches) ? orientations[matches] : nothing
end
function matchright(x, y, orientations)
    matches = map(f -> (@views x[:,end] == f(y)[:,1]), orientations)
    any(matches) ? orientations[matches] : nothing
end

"""
[up down left right]
"""
function findmatches!(ms, x, y, orientations)
    !isnothing(matchup(x, y, orientations)) && (ms[1] = true; return ms)
    !isnothing(matchdown(x, y, orientations)) && (ms[2] = true; return ms)
    !isnothing(matchleft(x, y, orientations)) && (ms[3] = true; return ms)
    !isnothing(matchright(x, y, orientations)) && (ms[4] = true; return ms)
    return ms
end

function getcorners(tiles)
    corners = Int[]
    cornermatches = Vector{Bool}[]
    for (key, value) ∈ tiles
        ms = falses(4)
        for (key1, value1) ∈ tiles
            if (key1 != key) && (key1 ∉ corners)
                findmatches!(ms, tiles[key], tiles[key1], orientations)
            end
            ms == trues(4) && break
        end
        if sum(ms) == 2 
            push!(corners, key)
            push!(cornermatches, ms)
        end
    end
    corners, cornermatches
end

function totopleft(ms, x)
    ms == [true, false, false, true] && return rotr90(x)
    ms == [true, false, true, false] && return rot180(x)
    ms == [false, true, true, false] && return rotl90(x)
    return x
end

function countmatches1(datastrings)
    tiles = readtiles(datastrings)
    corners, cornermatches = getcorners(tiles)
    prod(corners)
end

function countmatches2(datastrings)
    tiles = readtiles(datastrings)
    corners, cornermatches = getcorners(tiles)
    m = convert(Int, sqrt(length(tiles)))
    n = size(first(tiles).second,1)-2
    image = Matrix{Bool}(undef, m*n, m*n)
    ids = zeros(Int, m, m)

    indextopleft = 1
    ids[1,1] = corners[indextopleft]
    tiles[corners[indextopleft]] = totopleft(cornermatches[indextopleft], tiles[corners[indextopleft]])
    image[1:n,1:n] = tiles[corners[indextopleft]][2:end-1,2:end-1]

    for i ∈ 1:m
        for j ∈ 1:m
            if ids[i,j] == 0
                for (key, tile) ∈ tiles
                    if key ∉ ids
                        if (i > 1) && (j == 1)
                            f = matchdown(tiles[ids[i-1,j]], tile, orientations)
                            if !isnothing(f)
                                tiles[key] = first(f)(tile)
                                ids[i,j] = key
                                istart = (i - 1) * n + 1
                                jstart = (j - 1) * n + 1
                                image[istart:istart+n-1,jstart:jstart+n-1] = tiles[key][2:end-1,2:end-1]
                                break
                            end
                        else
                            f = matchright(tiles[ids[i,j-1]], tile, orientations)
                            if !isnothing(f)
                                tiles[key] = first(f)(tile)
                                ids[i,j] = key
                                istart = (i - 1) * n + 1
                                jstart = (j - 1) * n + 1
                                image[istart:istart+n-1,jstart:jstart+n-1] = tiles[key][2:end-1,2:end-1]
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    template = open("template.txt") do f
        xs = @pipe read(f, String) |> split(_, "\n")
        m = length(xs)
        n = length(xs[1])
        a = falses(m, n)
        for i ∈ 1:m
            for j ∈ 1:n
                xs[i][j] == '#' && (a[i,j]=true)
            end
        end
        a
    end

    mt, nt = size(template)
    mi, ni = size(image)
    numones = sum(template)
    for f ∈ orientations
        imagetmp = f(image)
        cnt = 0
        for i ∈ 1:mi-mt+1
            for j ∈ 1:ni-nt+1
                sum(imagetmp[i:i+mt-1,j:j+nt-1] .* template) == numones && (cnt += numones)
            end
        end
        cnt != 0 && break
    end
    sum(image) - cnt
end

datastrings = open("data.txt") do f
    @pipe read(f, String) |> split(_, "\n\n") |> split.(_, "\n")
end

countmatches1(datastrings) # 2.814 s (12576733 allocations: 481.81 MiB)
countmatches2(datastrings) # 2.815 s (13665172 allocations: 524.38 MiB)
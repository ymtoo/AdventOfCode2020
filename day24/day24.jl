function move(s::String)
    if s == "e"
        return [1, 0]
    elseif s == "se"
        return [1 // 2, -1]
    elseif s == "sw"
        return [-1 // 2, -1]
    elseif s == "w"
        return [-1, 0]
    elseif s == "nw"
        return [-1 // 2, 1]
    elseif s == "ne"
        return [1 // 2, 1]
    else
        throw(ArgumentError("Invalid input."))
    end
end

function findtile(ss)
    i = 1
    x = [0, 0]
    while i <= length(ss)
        a = string(ss[i])
        if a == "s" || a == "n"
            x += move(string(ss[i:i+1]))
            i += 2
        else
            x += move(a)
            i += 1
        end
    end
    x
end
function findblacktiles(datastrings)
    xs = map(x -> findtile(x), datastrings)
    blacktiles = Array{Rational{Int}}[]
    #cnt = 0
    for ux ∈ unique(xs)
        sum(map(x -> x == ux, xs)) % 2 == 1 && push!(blacktiles, ux)
        #cnt += sum(map(x -> x == ux, xs)) % 2 == 0 ? 0 : 1
    end
    blacktiles
    #cnt
end
countblack1(datastrings) = findblacktiles(datastrings) |> length

function flipdaily!(bts::Vector{T}, motions::Vector{T}) where T
    towhite = T[]
    toblack = T[]
    for bt ∈ bts
        cnt1 = 0
        for x ∈ bts
            if x != bt
                cnt1 += sum(abs, bt - x) < 2
            end
            cnt1 > 2 && break
        end 
        (cnt1 == 0 || cnt1 > 2) && push!(towhite, bt)
        for motion ∈ motions
            wt = bt + motion
            if (wt ∉ bts) && (wt ∉ toblack) 
                cnt2 = 0
                for x ∈ bts
                    cnt2 += sum(abs, wt - x) < 2
                    cnt2 > 2 && break
                end
                cnt2 == 2 && push!(toblack, wt)
            end
        end
    end
    rmindices = [i for (i, bt) ∈ enumerate(bts) if bt ∈ towhite]
    deleteat!(bts, rmindices)
    append!(bts, toblack)
    bts
end
tofloat(xs) = [convert.(Float32, x) for x ∈ xs]
function countblack2(datastrings, n)
    motions = [[1,0],[1 // 2,-1], [-1 // 2,-1],[-1,0],[-1 // 2,1],[1 // 2,1]] |> tofloat
    bts = findblacktiles(datastrings) |> tofloat
    for i ∈ 1:n
        flipdaily!(bts, motions)
    end
    length(bts)
end

datastrings = readlines("data.txt")
countblack1(datastrings)
countblack2(datastrings, 100)
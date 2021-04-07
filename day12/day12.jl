using Pipe: @pipe

struct Pose{IT<:Vector{Int}}
    xy::Vector{IT}
    v::Vector{IT}
end
Pose() = Pose([[0,0]], [[1, 0]])

rotate(v, θ) = round.(Int, [cos(θ) -sin(θ);sin(θ) cos(θ)] * v)

movenorth!(s::Pose, n::Int) = (push!(s.xy, last(s.xy) + [0,n]); push!(s.v, last(s.v)))
movesouth!(s::Pose, n::Int) = (push!(s.xy, last(s.xy) - [0,n]); push!(s.v, last(s.v)))
moveeast!(s::Pose, n::Int) = (push!(s.xy, last(s.xy) + [n,0]); push!(s.v, last(s.v)))
movewest!(s::Pose, n::Int) = (push!(s.xy, last(s.xy) - [n,0]); push!(s.v, last(s.v)))
moveleft!(s::Pose, θ::Int) = (push!(s.v, rotate(last(s.v), deg2rad(θ))); push!(s.xy, last(s.xy)))
moveright!(s::Pose, θ::Int) = (push!(s.v, rotate(last(s.v), -deg2rad(θ))); push!(s.xy, last(s.xy)))
moveforward!(s::Pose, n::Int) = (push!(s.xy, last(s.xy) + n .* last(s.v)); push!(s.v, last(s.v)))

actions = Dict('N' => movenorth!,
               'S' => movesouth!,
               'E' => moveeast!,
               'W' => movewest!,
               'L' => moveleft!,
               'R' => moveright!,
               'F' => moveforward!)

function trackship1(ds)
    s = Pose()
    for d in ds
        actions[d[1]](s, parse(Int, d[2:end]))
    end
    s
end
getshipdistance1(ds) = @pipe trackship1(ds).xy |> last |> sum(abs, _)

function trackship2(ds)
    w = Pose([[10,1]],[[0,1]])
    s = Pose()
    for d in ds
        if d[1] == 'F'
            actions[d[1]](w, 0)
            push!(s.xy, last(s.xy) + parse(Int, d[2:end]) .* last(w.xy))
        else
            if d[1] == 'L'
                push!(w.xy, rotate(last(w.xy), deg2rad(parse(Int, d[2:end]))))
            elseif d[1] == 'R'
                push!(w.xy, rotate(last(w.xy), deg2rad(-parse(Int, d[2:end]))))
            else
                actions[d[1]](w, parse(Int, d[2:end]))
            end
            push!(s.xy, last(s.xy))
        end
    end
    s
end
getshipdistance2(ds) = @pipe trackship2(ds).xy |> last |> sum(abs, _)

ds = readlines("data.csv")
getshipdistance1(ds) # 196.116 μs (4383 allocations: 284.08 KiB)
getshipdistance2(ds) # 189.843 μs (4598 allocations: 331.95 KiB)
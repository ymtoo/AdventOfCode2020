struct BitMask{IT<:Integer,BT}
    indices::Vector{IT}
    values::Vector{BT}
end

function getbitmask(datastring)
    xs = split(datastring, "= ") |> last |> reverse
    indices = Int[]
    values = Union{Missing,Bool}[]
    for (i, x) ∈ enumerate(xs)
        push!(indices, i)
        if x == 'X'
            push!(values, missing) 
        elseif x == '1' 
            push!(values, true) 
        else
            push!(values, false)
        end
    end
    BitMask(indices, values)
end
bm = getbitmask(datastrings[1])

function notexistpush!(memindices, memvalues, memindex, memvalue)
    if memindex ∈ memindices
        memvalues[memindices .== memindex] .= memvalue 
    else
        push!(memindices, memindex)
        push!(memvalues, memvalue)
    end
    memindices, memvalues
end

function masking_write1!(memindices, memvalues, bm, s)
    memindex = parse(Int, first(split(s[5:end], ']')))
    n = split(s, "= ") |> last |> x -> parse(Int, x)
    vs = digits(Bool, n, base=2, pad=36)
    for (i, a) ∈ zip(bm.indices, bm.values)
        if a !== missing
            a === true ? vs[i] = true : vs[i] = false
        end
    end
    memvalue  = reverse(vs) |> bits2int
    notexistpush!(memindices, memvalues, memindex, memvalue)
end

function bits2int(bs)
    acc = 0
    for (i, b) ∈ enumerate(reverse(bs))
        b === true && (acc += 2 ^ (i-1))
    end
    acc
end

function initialize(datastrings, masking_write)
    memindices = Int[]
    memvalues = Int[]
    bm = getbitmask(datastrings[1])
    for s ∈ datastrings[2:end]
        if startswith(s, "mask") 
            bm = getbitmask(s)
        else # startswith(s, "mem")
            masking_write(memindices, memvalues, bm, s)
        end
    end
    memvalues
end

function masking_write2!(memindices, memvalues, bm, s)
    m = parse(Int, first(split(s[5:end], ']')))
    is = digits(Bool, m, base=2, pad=36)
    memvalue = split(s, "= ") |> last |> x -> parse(Int, x)
    for (i, a) ∈ zip(bm.indices, bm.values)
        if a !== false
            a === true && (is[i] = true)
        end
    end
    missingindices = findall(ismissing.(bm.values))
    for j ∈ 0:(2^length(missingindices)-1)
        istmp = copy(is)
        istmp[missingindices] .= digits(j, base=2, pad=length(missingindices))
        memindex = reverse(istmp) |> bits2int
        notexistpush!(memindices, memvalues, memindex, memvalue)
    end
    memindices, memvalues
end

# function masking_write3!(memindices, memvalues, bm, s)
#     m = parse(Int, first(split(s[5:end], ']')))
# end

getsumm1(datastrings) = initialize(datastrings, masking_write1!) |> sum
getsumm2(datastrings) = initialize(datastrings, masking_write2!) |> sum

datastrings = readlines("data.csv")
getsumm1(datastrings) # 797.954 μs (7720 allocations: 888.44 KiB)
getsumm2(datastrings) # 1.065 s (308537 allocations: 68.29 MiB)
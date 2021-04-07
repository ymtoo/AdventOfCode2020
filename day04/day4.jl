using DataFrames
using Pipe:@pipe

function string2dataframe(datastrings)
    n = length(datastrings)
    df = DataFrame(byr=Vector{Union{Missing,Int}}(missing, n),
                   iyr=Vector{Union{Missing,Int}}(missing, n),
                   eyr=Vector{Union{Missing,Int}}(missing, n),
                   hgt=Vector{Union{Missing,String}}(missing, n),
                   hcl=Vector{Union{Missing,String}}(missing, n),
                   ecl=Vector{Union{Missing,String}}(missing, n),
                   pid=Vector{Union{Missing,String}}(missing, n),
                   cid=Vector{Union{Missing,Int}}(missing, n))
    for (i, datastring) ∈ enumerate(datastrings)
        x = split(replace(datastring, "\n"=>" "), " ")
        for field ∈ x
            name, item = split(field, ":")
            typeitem = eltype(df[!,name]).b
            df[i,name] = typeitem !== String ? parse(typeitem, item) : item
        end
    end
    df
end

function isvalid1(df::DataFrame)
    count([!any(ismissing, row) for row in eachrow(df[!,Not(:cid)])])
end
isvalid1(datastrings::Vector{T}) where {T<:AbstractString} = string2dataframe(datastrings) |> isvalid1

byrisvalid(x) = x ∈ 1920:2002
iyrisvalid(x) = x ∈ 2010:2020
eyrisvalid(x) = x ∈ 2020:2030
hgtisvalid(x) = x[end-1:end] ∈ ["cm","in"] && (x[end-1:end] == "cm" ? parse(
    Int, x[1:end-2]) ∈ (150:193) : parse(Int, x[1:end-2]) ∈ (59:76))
hclisvalid(x) = occursin(r"^#[0-9a-f]{6}$", x)#!isnothing(match(r"#[\d,a-f]{6}$", x))
eclisvalid(x) = x ∈ ["amb","blu","brn","gry","grn","hzl","oth"]
pidisvalid(x) = occursin(r"^\d{9}$", x)

function isvalid2(df::DataFrame)
    summ = 0
    for row in eachrow(df[!,Not(:cid)])
        if !any(ismissing, row)
            if (byrisvalid(row.byr) && iyrisvalid(row.iyr) &&
                eyrisvalid(row.eyr) && hgtisvalid(row.hgt) &&
                hclisvalid(row.hcl) && eclisvalid(row.ecl) &&
                pidisvalid(row.pid))
                 summ += 1
            end
        end
    end
    summ
end
isvalid2(datastrings::Vector{T}) where {T<:AbstractString} = string2dataframe(datastrings) |> isvalid2

datastrings = open("data.csv") do f
    @pipe read(f, String) |> 
    split(_, "\n\n")
end
isvalid1(datastrings) #2.130 ms (29826 allocations: 1.39 MiB)
isvalid2(datastrings) #2.311 ms (31754 allocations: 1.47 MiB)

df = string2dataframe(datastrings)
isvalid1(df) #255.281 μs (3704 allocations: 90.59 KiB)
isvalid2(df) #441.923 μs (5633 allocations: 178.70 KiB)

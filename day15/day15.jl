function findnumber(numbers, n)
    d = Dict([(numbers[i], i) for i ∈ 1:length(numbers)-1])
    lastnumber = last(numbers)
    for i ∈ length(numbers)+1:n
        k1 = haskey(d, lastnumber) ? i - 1 - d[lastnumber] : 0
        d[lastnumber] = i-1
        lastnumber = k1
        # if length(d[lastnumber]) == 1 
        #     lastnumber = 0
        #     v = d[lastnumber]
        #     push!(v, i)
        #     length(v) > 2 && popfirst!(v)
        # else
        #     lastnumber = i - 1 - d[lastnumber][end-1]
        #     if haskey(d, lastnumber)
        #         push!(d[lastnumber], i)
        #         length(d[lastnumber]) > 2 && popfirst!(d[lastnumber])
        #     else
        #         d[lastnumber] = [i]
        #     end 
        # end
    end
    lastnumber
end

numbers = [15,5,1,4,7,0]

findnumber(numbers, 2020) # 99.822 μs (558 allocations: 67.47 KiB)
findnumber(numbers, 30000000) # 6.103 s (4860754 allocations: 657.02 MiB)
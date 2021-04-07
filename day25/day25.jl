cardpk, doorpk = parse.(Int, readlines("data.txt"))
subjectnumber = 7
divisor = 20201227 

value = 1
m = round(Int, log(divisor) ÷ log(value * subjectnumber))
value = (value * subjectnumber ^ (m+1)) % divisor 
m = round(Int, log(divisor) ÷ log(value * subjectnumber))

function getloopsize(pk)
    n = 0
    value = 1
    while true
        n += 1
        value = (value * subjectnumber) % divisor
        value == pk && break
    end
    n
end

function getencryptionkey(n, sn, divisor)
    value = 1
    for i ∈ 1:n
        value = (value * sn) % divisor
    end
    value
end
cardls = getloopsize(cardpk)
doorls = getloopsize(doorpk)
ek = getencryptionkey(cardls, doorpk, divisor)
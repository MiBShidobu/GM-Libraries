--[[
    GM-Libraries :: net.* Extensions
        by MiBShidobu
]]--

local g_LogarithmConstant = math.log(2)

--[[
    Name: ReversePower(number Number)
    Desc: Reverses a power of two(2^X) product to find 2 was raised by(X).
    State: LOCAL/SHARED
]]--

local function ReversePower(number)
    return math.log(number) / g_LogarithmConstant
end

--[[
    Name: net.WriteNumber(number Number)
    Desc: Writes a number, handles bit calculations and negative numbers for you.
    State: SHARED
]]--

function net.WriteNumber(number)
    local negative = number < 0
    local bits = math.ceil(ReversePower(math.ceil(negative and math.abs(number / 2) or number)))

    net.WriteBit(negative)
    net.WriteUInt(bits, 6)
    if negative then
        net.WriteInt(number, bits)

    else
        net.WriteUInt(number, bits)
    end
end

--[[
    Name: net.ReadNumber()
    Desc: Returns a number using the net.WriteNumber format.
    State: SHARED
]]--

function net.ReadNumber()
    if net.ReadBit() > 0 then
        net.ReadInt(net.ReadUInt(6))

    else
        net.ReadUInt(net.ReadUInt(6))
    end
end

if serialize then -- GM-Serialize, note: color support
    --[[
        Name: net.WriteVariable(variable Value)
        Desc: Writes a variable, automatically handling typing with serialization.
        State: SHARED
    ]]--

    function net.WriteVariable(value)
        local data = util.Compress(serialize.Encode(value))
        net.WriteUInt(#data, 16)
        net.WriteData(data, #data)
    end

    --[[
        Name: net.ReadVariable()
        Desc: Returns a number using the net.WriteVariable format.
        State: SHARED
    ]]--

    function net.ReadVariable()
        return serialize.Decode(util.Decompress(net.ReadData(net.ReadUInt(16))))
    end

elseif pon then -- pON, note: no color support
    function net.WriteVariable(value)
        local data = util.Compress(pon.encode{value})
        net.WriteUInt(#data, 16)
        net.WriteData(data, #data)
    end

    function net.ReadVariable()
        return pon.decode(util.Decompress(net.ReadData(net.ReadUInt(16))))[1]
    end

elseif von then -- vON, note: no color support
    function net.WriteVariable(value)
        local data = util.Compress(von.deserialize{value})
        net.WriteUInt(#data, 16)
        net.WriteData(data, #data)
    end

    function net.ReadVariable()
        return von.serialize(util.Decompress(net.ReadData(net.ReadUInt(16))))[1]
    end

else -- Crappy net.Read/WriteType support as fallback. BUT DO NOTE! IT DOES SUPPORT COLOR!
    net.WriteVariable = net.WriteType
    net.ReadVariable = net.ReadType
end
--[[
    GM-Libraries :: Set Library Script
        by MiBShidobu
]]--

local SET = {}

--[[
    Name: SET[index]
    Desc: Returns a pushed value from the set.
    State: SHARED
]]--

SET.__index = function (self, key)
    if self.m_Array[key] then
        return self.m_Array[key]
    end

    return SET[key]
end

--[[
    Name: #SET
    Desc: Returns how many values were pushed into the set.
    State: SHARED
]]--

SET.__len = function (self)
    return self.m_Count
end

--[[
    Name: SET()
    Desc: Returns an iterator for looping the set.
    State: SHARED
]]--

SET.__call = function (self)
    local index = 0
    local count = self.m_Count
    return function ()
        index = index + 1
        if index <= count then
            return index, self.m_Array[index]
        end
    end
end

--[[
    Name: SET:push(variable Value)
    Desc: Pushes the value into the set if it doesn't exist.
    State: SHARED
]]--

function SET.push(set, value)
    if value == nil then
        error("cannot manipulate a nil value")
    end

    if not set.m_Members[value] then
        set.m_Count = set.m_Count + 1

        set.m_Members[value] = set.m_Count
        set.m_Array[set.m_Count] = value
    end
end

--[[
    Name: SET:remove(variable Value)
    Desc: Removes the value from the set if it exists.
    State: SHARED
]]--

function SET.remove(set, value)
    if value == nil then
        error("cannot manipulate a nil value")
    end

    if set.m_Members[value] then
        set.m_Count = set.m_Count - 1

        table.remove(set.m_Array, set.m_Members[value])
        set.m_Members[value] = nil

        for index=1, set.m_Count do
            local value = set.m_Array[index]
            set.m_Members[value] = index
        end
    end
end

--[[
    Name: SET:index(variable Value)
    Desc: Returns the index of the value in the set if exists.
    State: SHARED
]]--

function SET.index(set, value)
    return set.m_Members[value]
end

--[[
    Name: SET:exists(variable Value)
    Desc: Returns if the value is in the set.
    State: SHARED
]]--

function SET.exists(set, value)
    return set.m_Members[value] and true or false
end

--[[
    Name: SET:count()
    Desc: Returns how many values were pushed into the set.
    State: SHARED
]]--

function SET.count(set)
    return set.m_Count
end

--[[
    Name: SET:pop()
    Desc: Removes and returns the last value in the set.
    State: SHARED
]]--

function SET.pop(set)
    if set.m_Count > 0 then
        local value = set.m_Array[set.m_Count]
        set:remove(value)

        return value
    end 
end

--[[
    Name: SET:shift()
    Desc: Removes and returns the first value in the set.
    State: SHARED
]]--

function SET.shift(set)
    if set.m_Count > 0 then
        local value = set.m_Array[1]
        set:remove(value)

        return value
    end 
end

local SETTABLE = {}

-- Allows indxing of set metatable as 'set.*'.

SETTABLE.__index = function (self, key)
    if SET[key] then
        return SET[key]
    end

    return SETTABLE[key]
end

--[[
    Name: set()
    Desc: Returns an empty set.
    State: SHARED
]]--

SETTABLE.__call = function ()
    return setmetatable({
        m_Count = 0,
        m_Members = {},
        m_Array = {}
    }, SET)
end

--[[
    Name: set.IsSet(variable Value)
    Desc: Returns if the value is a set.
    State: SHARED
]]--

function SETTABLE.IsSet(set)
    return getmetatable(set) == SET
end

set = setmetatable({}, SETTABLE)